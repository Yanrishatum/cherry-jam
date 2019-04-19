package gasm.core.components;

import gasm.core.api.singnals.TResize;
import gasm.core.enums.Orientation;
import gasm.core.utils.Signal1;
import gasm.core.math.geom.Point;
import gasm.core.enums.ComponentType;

class AppModelComponent extends Component {
    /**
    * Device orientation.
    **/
    public var orientation:Orientation;
    public var stageSize:Point = {x:0, y:0};
    public var resizeSignal:Signal1<TResize>;
    public var stageMouseX:Float;
    public var stageMouseY:Float;

    public function new() {
        componentType = ComponentType.Model;
        resizeSignal = new Signal1<TResize>();
    }
}
