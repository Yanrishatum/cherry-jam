package gasm.core.components;

import motion.actuators.GenericActuator;
import motion.Actuate;
import gasm.core.components.SpriteModelComponent;
import gasm.core.enums.ComponentType;
import gasm.core.Component;

class TweenComponent extends Component {
    var _properties:Dynamic;
    var _startProperties:Dynamic;
    var _duration:Float;
    var _spriteModel:SpriteModelComponent;
    var _completeFunc:Void -> Void;
    var _updateFunc:Void -> Void;

    public function new(properties:Dynamic, duration:Float, startProperties:Dynamic = null) {
        componentType = ComponentType.Actor;
        _properties = properties;
        _startProperties = startProperties;
        _duration = duration;
    }

    override public function init() {
        _spriteModel = owner.get(SpriteModelComponent);
        if (_startProperties != null) {
            for (field in Reflect.fields(_startProperties)) {
                Reflect.setField(_spriteModel, field, Reflect.field(_startProperties, field));
            }
        }
        tween();
    }

    public function onComplete(func:Void -> Void) {
        _completeFunc = func;
    }

    public function onUpdate(func:Void -> Void) {
        _updateFunc = func;
    }

    inline function tween() {
        if (_spriteModel != null) {
            var tween:GenericActuator<SpriteModelComponent> = Actuate.tween(_spriteModel, _duration, _properties);
            tween.onComplete(function() {
                if (_completeFunc != null) {
                    _completeFunc();
                }
            });
            tween.onUpdate(function() {
                if (_updateFunc != null) {
                    _updateFunc();
                }
            });
        } else {
            trace("warn", "Attempting to tween entity without a sprite model. Ensure you have a component with ComponentType.GRAPHICS in the entity you like to tween.");
        }
    }
}