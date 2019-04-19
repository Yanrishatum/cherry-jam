package gasm.extra.components;
import haxe.Timer;
import gasm.core.Component;
import gasm.core.enums.ComponentType;

/**
 * ...
 * @author Leo Bergman
 */
class FPSComponent extends Component {
    static var _cacheCount:Int = 0;
    static var _times:Array <Float> = [];

    public var fps(default, null):Int;

    public function new() {
        componentType = ComponentType.ActiveModel;
    }

    override public function update(delta:Float) {
        var currentTime = Timer.stamp();
        _times.push(currentTime);
        while (_times[0] < currentTime - 1) {
            _times.shift();
        }
        var currentCount = _times.length;
        _cacheCount = currentCount;
        fps = Math.round((currentCount + _cacheCount) / 2);
    }

}