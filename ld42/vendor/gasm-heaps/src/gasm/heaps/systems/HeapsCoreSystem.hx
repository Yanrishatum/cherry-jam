package gasm.heaps.systems;

import h2d.Object as Sprite;
import gasm.heaps.components.HeapsSpriteComponent;
import gasm.core.components.SpriteModelComponent;
import gasm.core.Component;
import gasm.core.enums.ComponentType;
import gasm.core.System;
import gasm.core.ISystem;
import gasm.core.enums.SystemType;
import h2d.Scene;

class HeapsCoreSystem extends System implements ISystem {
    public var root(default, null):Scene;


    public function new(root:Scene) {
        super();
        this.root = root;
        type = SystemType.CORE;
        componentFlags.set(ComponentType.GraphicsModel);
    }

    public function update(comp:Component, delta:Float) {
        if (!comp.inited) {
            comp.init();
            comp.inited = true;
        }
        switch(comp.componentType) {
            case ComponentType.GraphicsModel: updateMouseCoords(comp);
            default: null;
        }
        comp.update(delta);
    }

    private function updateMouseCoords(comp:Component) {
        var model:SpriteModelComponent = cast comp;
        model.stageMouseX = root.mouseX;
        model.stageMouseY = root.mouseY;
        var spriteComponent:HeapsSpriteComponent = model.owner.get(HeapsSpriteComponent);
        if (spriteComponent != null) {
            var sp:Sprite = cast spriteComponent.sprite;
            var p:h2d.col.Point  = sp.globalToLocal(new h2d.col.Point(root.mouseX, root.mouseY));
            model.mouseX = p.x;
            model.mouseY = p.y;
        }
    }
}
