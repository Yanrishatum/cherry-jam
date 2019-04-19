package gasm.core.components;

import gasm.core.math.geom.Point;
import gasm.core.Component;
import gasm.core.components.SpriteModelComponent;
import gasm.core.enums.ComponentType;

class OffsetComponent extends Component {
    public var offset(default, null):Point;

    public function new(?x:Float = 0, ?y:Float = 0) {
        offset = {x:x, y:y};
        componentType = ComponentType.Actor;
    }

    override public function update(dt:Float) {
        var model:SpriteModelComponent = owner.get(SpriteModelComponent);
        model.offsetX = offset.x;
        model.offsetY = offset.y;
    }
}