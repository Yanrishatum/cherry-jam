package gasm.heaps.components;

import gasm.core.Component;
import gasm.core.components.AppModelComponent;
import gasm.core.components.SpriteModelComponent;
import gasm.core.enums.ComponentType;
import gasm.core.enums.EventType;
import gasm.core.events.api.IEvent;
import h2d.Object as Sprite;
import hxd.Event;

/**
 * ...
 * @author Leo Bergman
 */
class HeapsSpriteComponent extends Component {
    public var sprite(default, default):Sprite;
    public var mouseEnabled(default, set):Bool;
    public var root(default, default):Bool;
    public var roundPixels(default, default):Bool;

    var _model:SpriteModelComponent;
    var _lastW:Float;
    var _lastH:Float;
    var _interactive:h2d.Interactive;
    var _stage:hxd.Window;
    var _appModel:AppModelComponent;

    public function new(sprite:Null<Sprite> = null, mouseEnabled:Bool = false, roundPixels:Bool = false) {
        if (sprite == null) {
            sprite = mouseEnabled ? cast new h2d.Interactive(0, 0) : new Sprite();
        }
        if (mouseEnabled) {
            _interactive = cast sprite;
            _interactive.propagateEvents = true;
        }
        this.sprite = sprite;
        this.roundPixels = roundPixels;
        componentType = ComponentType.Graphics;
    }

    override public function setup() {
        sprite.name = owner.id;
    }

    override public function init() {
        _model = owner.get(SpriteModelComponent);
        _appModel = owner.getFromParents(AppModelComponent);
        var w = sprite.getSize().width;
        var h = sprite.getSize().height;
        if (w > 0) {
            _model.width = w;
            _model.height = h;
        }
        // TODO: Implement mask support
        /*
        var mask:Mask = _model.mask;
        if (mask != null) {
            sprite.addChild(mask);
            sprite.mask = mask;
        }*/
        _stage = hxd.Window.getInstance();
        if (_interactive != null) {
            addEventListeners();
        }
        onResize();
    }

    override public function update(dt:Float) {
        if(owner.id == 'winCountupHolder') {
            trace("winCountupHolder:" + _model.visible + "::" + _model.x + "::" + _model.y);
        }
        if(owner.id == 'winCountup') {
            trace("winCountup:" + _model.visible + "::" + _model.x + "::" + _model.y);
        }
        sprite.x = _model.x + _model.offsetX;
        sprite.y = _model.y + _model.offsetY;
        var bounds = sprite.getBounds();

        var w = bounds.width;
        var h = bounds.height;

        if (w != _lastW) {
            _model.width = w;
            if(_interactive != null) {
                _interactive.width = w;
            }
        }
        if (h != _lastH) {
            _model.height = h;
            if(_interactive != null) {
                _interactive.height = h;
            }
        }

        if (_model.width != _lastW) {
            w = _model.width;
        }
        if (_model.height != _lastH) {
            h = _model.height;
        }
        if (_model.xScale != sprite.scaleX) {
            sprite.scaleX = _model.xScale;
        }
        if (_model.yScale != sprite.scaleY) {
            sprite.scaleY = _model.yScale;
        }

        if (roundPixels) {
            _model.x = Math.round(_model.x);
            _model.y = Math.round(_model.y);
            _model.width = Math.round(_model.width);
            _model.height = Math.round(_model.height);
            _model.stageSize.x = Math.round(_model.stageSize.x);
            _model.stageSize.y = Math.round(_model.stageSize.y);
        }

        if (_model.width != _lastW || _model.height != _lastH) {
            onResize();
        }

        _lastW = _model.width;
        _lastH = _model.height;
        sprite.visible = _model.visible;
    }

    override public function dispose() {
        removeEventListeners();
        if (sprite.parent != null) {
            sprite.parent.removeChild(sprite);
        }
        stopDrag();
        sprite.removeChildren();
    }


    function onClick(event:Event) {
        _model.triggerEvent(EventType.PRESS, { x:_stage.mouseX, y:_stage.mouseY }, owner);
    }

    function onDown(event:Event) {
        _model.triggerEvent(EventType.DOWN, { x:_stage.mouseX, y:_stage.mouseY }, owner);
        startDrag();
    }

    function onUp(event:Event) {
        _model.triggerEvent(EventType.UP, { x:_stage.mouseX, y:_stage.mouseY }, owner);
        stopDrag();
    }

    function onStageUp(event:IEvent) {
        stopDrag();
    }

    function onOver(event:Event) {
        _model.triggerEvent(EventType.OVER, { x:_stage.mouseX, y:_stage.mouseY }, owner);
    }

    function onOut(event:Event) {
        _model.triggerEvent(EventType.OUT, { x:_stage.mouseX, y:_stage.mouseY }, owner);
    }

    function onMove(event:Event) {
        _model.triggerEvent(EventType.MOVE, { x:_stage.mouseX, y:_stage.mouseY }, owner);
    }

    function onDrag(event:IEvent) {
        var stage = hxd.Window.getInstance();
        _model.triggerEvent(EventType.DRAG, { x:_appModel.stageMouseX, y:_appModel.stageMouseY }, owner);
    }

    function onResize(?event:Event) {
        // _model.triggerEvent(EventType.RESIZE, { x:_stage.width, y:_stage.height}, owner);
    }

    function stopDrag() {
        if (_model != null) {
            _model.removeHandler(EventType.MOVE, onDrag);
        }
    }

    function startDrag() {
        _model.addHandler(EventType.MOVE, onDrag);
    }

    inline function addEventListeners() {
        if (_interactive != null) {
            _interactive.onClick = onClick;
            _interactive.onPush = onDown;
            _interactive.onRelease = onUp;
            _interactive.onOver = onOver;
            _interactive.onOut = onOut;
            _interactive.onMove = onMove;
            var rootSmc:SpriteModelComponent = owner.getFromRoot(SpriteModelComponent);
            rootSmc.addHandler(EventType.UP, onStageUp);
            var smc:SpriteModelComponent = owner.get(SpriteModelComponent);
            smc.addHandler(EventType.UP, onStageUp);
        }
    }

    inline function removeEventListeners() {
        if (_interactive != null) {
            _interactive.onClick = null;
            _interactive.onPush = null;
            _interactive.onRelease = null;
            _interactive.onOver = null;
            _interactive.onOut = null;
            _interactive.onMove = null;
            var rootSmc:SpriteModelComponent = owner.getFromRoot(SpriteModelComponent);
            rootSmc.removeHandler(EventType.UP, onStageUp);
            var smc:SpriteModelComponent = owner.get(SpriteModelComponent);
            smc.removeHandler(EventType.UP, onStageUp);
            if (_model != null) {
                _model.removeHandler(EventType.MOVE, onDrag);
            }
        }
    }

    function set_mouseEnabled(val:Bool):Bool {
        if (val) {
            addEventListeners();
        } else {
            removeEventListeners();
        }
        return val;
    }
}