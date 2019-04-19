package gasm.core;
import buddy.BuddySuite;
import gasm.core.systems.CoreSystem;
import gasm.core.systems.ActorSystem;
import gasm.core.Engine;
import gasm.core.Component;
import gasm.core.enums.SystemType;
import gasm.core.enums.ComponentType;
import gasm.core.ISystem;
import gasm.core.System;
import haxe.EnumFlags;

using buddy.Should;
/**
 * ...
 * @author Leo Bergman
 */
class EngineTest extends BuddySuite {

    public function new() {
        describe("Engine", {
            describe("constructor", {
                it("should add core and actor systems", {
                    var systems:Array<ISystem> = [];
                    var engine = new Engine(systems);
                    systems[0].should.beType(CoreSystem);
                    systems[1].should.beType(ActorSystem);

                });
                it("should sort systems according to system type", {
                    var systems:Array<ISystem> = [
                        new SoundSystem(),
                        new RenderingSystem()
                    ];

                    var engine = new Engine(systems);
                    systems[2].should.beType(RenderingSystem);
                    systems[3].should.beType(SoundSystem);
                });
            });

            describe("updateEntity", {
                it("should update GraphicsModelComponent before GraphicsComponent", {
                    var systems:Array<ISystem> = [
                        new RenderingSystem()
                    ];

                    var engine = new Engine(systems);
                    var gc = new GraphicsComponent();
                    var mc = new GraphicsModelComponent();
                    engine.baseEntity.add(gc).add(mc);
                    engine.tick();
                    // GraphicsComponent will set flag if GraphicsModelComponent been updated first
                    gc.modelUpdated.should.be(true);
                });

                it("should update SoundModelComponent before SoundComponent", {
                    var systems:Array<ISystem> = [
                        new SoundSystem()
                    ];

                    var engine = new Engine(systems);
                    var sc = new SoundComponent();
                    var mc = new SoundModelComponent();
                    engine.baseEntity.add(sc).add(mc);
                    engine.tick();
                    // SoundComponent will set flag if SoundModelComponent been updated first
                    sc.modelUpdated.should.be(true);
                });

                it("should update GraphicsComponent before SoundComponent", {
                    var systems:Array<ISystem> = [
                        new SoundSystem(),
                        new RenderingSystem()
                    ];

                    var engine = new Engine(systems);
                    var sc = new SoundComponent();
                    var gc = new GraphicsComponent();
                    engine.baseEntity.add(sc).add(gc);
                    engine.tick();
                    // SoundComponent will set flag if GraphicsComponent been updated first
                    sc.graphicsUpdated.should.be(true);
                });
            });
        });
    }
}

class RenderingSystem extends System implements ISystem {
    public function new() {
        super();
        type = SystemType.RENDERING;
        componentFlags.set(ComponentType.Graphics);
        componentFlags.set(ComponentType.Text);
    };

    public function update(comp:Component, delta:Float):Void {
        if (!comp.inited) {
            comp.init();
            comp.inited = true;
        }
        comp.update(delta);
    };
}

class SoundSystem extends System implements ISystem {
    public function new() {
        super();
        type = SystemType.SOUND;
        componentFlags.set(ComponentType.Sound);
    };

    public function update(comp:Component, delta:Float):Void {
        if (!comp.inited) {
            comp.init();
            comp.inited = true;
        }
        comp.update(delta);
    };
}

class GraphicsComponent extends Component {
    public var updated:Bool;
    public var modelUpdated:Bool;

    public function new() {
        componentType = ComponentType.Graphics;
    }

    override public function update(dt:Float) {
        var model = owner.get(GraphicsModelComponent);
        if (model != null && model.updated) {
            modelUpdated = true;
        }
        updated = true;
    }
}

class GraphicsModelComponent extends Component {
    public var updated:Bool;

    public function new() {
        componentType = ComponentType.GraphicsModel;
    }

    override public function update(dt:Float) {
        updated = true;
    }
}

class SoundComponent extends Component {
    public var updated:Bool;
    public var modelUpdated:Bool;
    public var graphicsUpdated:Bool;

    public function new() {
        componentType = ComponentType.Sound;
    }

    override public function update(dt:Float) {
        var model = owner.get(SoundModelComponent);
        if (model != null && model.updated) {
            modelUpdated = true;
        }
        var graphics = owner.get(GraphicsComponent);
        if (graphics != null && graphics.updated) {
            graphicsUpdated = true;
        }
        updated = true;
    }
}

class SoundModelComponent extends Component {
    public var updated:Bool;

    public function new() {
        componentType = ComponentType.SoundModel;
    }

    override public function update(dt:Float) {
        updated = true;
    }
}