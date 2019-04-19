package gasm.core.events;

import gasm.core.events.api.IEvent;
import gasm.core.math.geom.Point;

class ResizeEvent implements IEvent {
    public var entity(default, null):Entity;
    public var size(default, null):Point;

    public function new(size:Point, entity:Entity) {
        this.entity = entity;
        this.size = size;
    }
}
