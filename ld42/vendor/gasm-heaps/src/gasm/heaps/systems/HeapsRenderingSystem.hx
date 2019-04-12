package gasm.heaps.systems;

import gasm.core.enums.ComponentType;
import gasm.heaps.components.HeapsTextComponent;
import gasm.core.components.SpriteModelComponent;
import gasm.core.Component;
import gasm.core.enums.SystemType;
import gasm.core.ISystem;
import gasm.core.System;
import gasm.heaps.components.HeapsSpriteComponent;
import h2d.Scene;

/**
 * ...
 * @author Leo Bergman
 */

class HeapsRenderingSystem extends System implements ISystem {
    public var root(default, null):Scene;

    public function new(root:Scene) {
        super();
        this.root = root;
        type = SystemType.RENDERING;
        componentFlags.set(ComponentType.Graphics);
        componentFlags.set(ComponentType.Text);
    }

    public function update(comp:Component, delta:Float) {
        if (!comp.inited) {
            comp.init();
            var model:SpriteModelComponent = comp.owner.get(SpriteModelComponent);
            if (comp.owner.parent != null) {
                var parent:HeapsSpriteComponent = comp.owner.parent.get(HeapsSpriteComponent);
                switch(comp.componentType) {
                    case ComponentType.Graphics:
                        var child = cast(comp, HeapsSpriteComponent).sprite;
                        if (parent != null && parent != comp) {
                            parent.sprite.addChild(child);
                        } else {
                            root.addChild(child);
                        }
                        var size = child.getSize();
                        model.origWidth = size.width;
                        model.origHeight = size.height;
                    case ComponentType.Text:
                        var child = cast(comp, HeapsTextComponent).textField;
                        if (parent != null && parent != comp) {
                            parent.sprite.addChild(child);
                        } else {
                            root.addChild(child);
                        }
                        var size = child.getSize();
                        model.origWidth = size.width;
                        model.origHeight = size.height;
                    default:
                }
            } else if(Std.is(comp, HeapsSpriteComponent)){
                var spc:HeapsSpriteComponent = cast comp;
                spc.root = true;
                var size = spc.sprite.getSize();
                model.origWidth = size.width;
                model.origHeight = size.height;
            }
            comp.inited = true;
        }
        comp.update(delta);
    }
}