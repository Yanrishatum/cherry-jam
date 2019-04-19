package gasm.extra.behaviors;

/**
 * ...
 * @author Leo Bergman
 */
@:final
class BounceBehavior {
    var _gravity:Float = .5;
    var _minX:Float;
    var _minY:Float;
    var _maxX:Float;
    var _maxY:Float;
    var _x:Float;
    var _y:Float;
    var _speedX:Float;
    var _speedY:Float;

    inline public function new(?gravity:Float = 0.5, ?minX:Float = 0, ?minY:Float = 0, ?maxX:Float = 800, ?maxY:Float = 600, ?speed:Float = 5) {
        _gravity = gravity;
        _minX = minX;
        _minY = minY;
        _maxX = maxX;
        _maxY = maxY;
        _speedX = Math.random() * speed;
        _speedY = Math.random() * speed;
    }

    inline public function act(x:Float, y:Float):{x:Float, y:Float} {
        x += _speedX;
        y += _speedY;
        _speedY += _gravity;

        if (x > _maxX) {
            _speedX *= -1;
            x = _maxX;
        }
        else if (x < _minX) {
            _speedX *= -1;
            x = _minX;
        }

        if (y > _maxY) {
            _speedY *= -0.8;
            y = _maxY;
            if (Math.random() > 0.5) {
                _speedY -= 3 + Math.random() * 4;
            }
        }
        else if (y < _minY) {
            _speedY = 0;
            y = _minY;
        }
        return { x:x, y:y };
    }

}