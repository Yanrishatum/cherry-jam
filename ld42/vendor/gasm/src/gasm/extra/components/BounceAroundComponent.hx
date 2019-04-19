package gasm.extra.components;

import gasm.core.Component;
import gasm.core.components.SpriteModelComponent;
import gasm.core.enums.ComponentType;

/**
 * ...
 * @author Leo Bergman
 */
class BounceAroundComponent extends Component {
    var _gravity:Float;
    var _minX:Float;
    var _minY:Float;
    var _maxX:Float;
    var _maxY:Float;

    public function new(gravity:Float = 0.5, minX:Float = 0, minY:Float = 0, maxX:Float = 800, maxY:Float = 600) {
        componentType = ComponentType.Actor;
        _gravity = gravity;
        _minX = minX;
        _minY = minY;
        _maxX = maxX;
        _maxY = maxY;
    }

    override public function init() {
        var model = owner.get(SpriteModelComponent);
        model.x = 0;
        model.y = 0;
        model.speedX = Math.random() * 5;
        model.speedY = (Math.random() * 5);
    }

    override public function update(delta:Float) {
        var model:SpriteModelComponent = owner.get(SpriteModelComponent);
        model.x += model.speedX;
        model.y += model.speedY;
        model.speedY += _gravity;

        if (model.x > _maxX) {
            model.speedX *= -1;
            model.x = _maxX;
        }
        else if (model.x < _minX) {
            model.speedX *= -1;
            model.x = _minX;
        }

        if (model.y > _maxY) {
            model.speedY *= -0.8;
            model.y = _maxY;
            if (Math.random() > 0.5) {
                model.speedY -= 3 + Math.random() * 4;
            }
        }
        else if (model.y < _minY) {
            model.speedY = 0;
            model.y = _minY;
        }
    }
}