package gasm.heaps.systems;
import gasm.core.Component;
import gasm.core.enums.ComponentType;
import gasm.core.ISystem;
import gasm.core.System;
import gasm.core.enums.SystemType;

/**
 * ...
 * @author Leo Bergman
 */

class HeapsSoundSystem extends System implements ISystem {
    public function new() {
        super();
        type = SystemType.SOUND;
        componentFlags.set(ComponentType.Sound);
    }

    public function update(comp:Component, delta:Float) {
        if (!comp.inited) {
            comp.init();
            comp.inited = true;
        }
        comp.update(delta);
    }
}