package gasm.core.events;
import gasm.core.events.api.IEvent;

/**
 * ...
 * @author Leo Bergman
 */
class InteractionEvent implements IEvent {

    public var pos(default, null):{ x:Float, y:Float };
    public var entity(default, null):Entity;

    public function new(pos:{x:Float, y:Float}, entity:Entity) {
        this.pos = pos;
        this.entity = entity;
    }

}