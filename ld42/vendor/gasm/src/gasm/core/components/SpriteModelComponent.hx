package gasm.core.components;
import gasm.core.math.geom.Point;
import gasm.core.events.InteractionEvent;
import gasm.core.enums.ComponentType;
import gasm.core.Component;
import gasm.core.enums.EventType;

/**
 * Model to interface between different graphics backends.
 * Automatically added when you add ComponentType.GRAPHICS to an Entity.
 * 
 * @author Leo Bergman
 */
class SpriteModelComponent extends Component {
    public var x(default, default):Float = 0;
    public var y(default, default):Float = 0;
    public var width(default, default):Float = -1;
    public var height(default, default):Float = -1;
    public var origWidth(default, default):Float = -1;
    public var origHeight(default, default):Float = -1;
    public var xScale(default, default):Float = 1;
    public var yScale(default, default):Float = 1;
    public var mouseX(default, default):Float = 0;
    public var mouseY(default, default):Float = 0;
    public var stageMouseX(default, default):Float = 0;
    public var stageMouseY(default, default):Float = 0;
    public var stageSize(default, default):Point = {x:0, y:0};
    public var offsetX(default, default):Float = 0;
    public var offsetY(default, default):Float = 0;
    public var speedX(default, default):Float;
    public var speedY(default, default):Float;
    public var interactive(default, default):Bool = false;
    public var visible(default, default):Bool = true;
    public var mask(default, default):Any;

    var _pressHandlers(default, default):Array<InteractionEvent -> Void>;
    var _overHandlers(default, default):Array<InteractionEvent -> Void>;
    var _outHandlers(default, default):Array<InteractionEvent -> Void>;
    var _moveHandlers(default, default):Array<InteractionEvent -> Void>;
    var _dragHandlers(default, default):Array<InteractionEvent -> Void>;
    var _downHandlers(default, default):Array<InteractionEvent -> Void>;
    var _upHandlers(default, default):Array<InteractionEvent -> Void>;
    var _resizeHandlers(default, default):Array<InteractionEvent -> Void>;

    public function new() {
        componentType = ComponentType.GraphicsModel;
        _pressHandlers = [];
        _overHandlers = [];
        _outHandlers = [];
        _moveHandlers = [];
        _dragHandlers = [];
        _downHandlers = [];
        _upHandlers = [];
        _resizeHandlers = [];
    }

    override public function dispose() {
        for (type in Type.allEnums(EventType)) {
            removeHandlers(type);
        }
    }

    public function addHandler(type:EventType, cb:InteractionEvent -> Void) {
        var handlers = getHandlers(type);
        handlers.push(cb);
    }

    public function removeHandler(type:EventType, cb:InteractionEvent -> Void) {
        var handlers = getHandlers(type);
        for (handler in handlers) {
            if (handler == cb) {
                handlers.remove(handler);
            }
        }
    }

    public function removeHandlers(type:EventType) {
        var handlers = getHandlers(type);
        handlers = [];
    }

    public function triggerEvent(type:EventType, point:{x:Float, y:Float}, owner:Entity) {
        var event = new InteractionEvent(point, owner);
        var handlers = getHandlers(type);
        for (handler in handlers) {
            handler(event);
        }
    }

    inline function getHandlers(type:EventType):Array<InteractionEvent -> Void> {
        return switch(type) {
            case PRESS: _pressHandlers;
            case OVER: _overHandlers;
            case OUT: _outHandlers;
            case MOVE: _moveHandlers;
            case DRAG: _dragHandlers;
            case DOWN: _downHandlers;
            case UP: _upHandlers;
            case RESIZE: _resizeHandlers;
        }
    }
}