package gasm.core.systems;

import gasm.core.System;
import gasm.core.ISystem;
import gasm.core.enums.SystemType;
import gasm.core.enums.ComponentType;

/**
 * Updates the actor components.
 * 
 * @author Leo Bergman
 */
class ActorSystem extends System implements ISystem {
    public function new() {
        super();
        type = SystemType.ACTOR;
        componentFlags.set(ComponentType.Actor);
    }

    inline public function update(comp:Component, delta:Float) {
        if (!comp.inited) {
            comp.init();
            comp.inited = true;
        }
        comp.update(delta);
    }
}