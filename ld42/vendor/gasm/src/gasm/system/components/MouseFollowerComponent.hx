package gasm.system.components;

import gasm.core.Component;
import gasm.core.components.SpriteModelComponent;
import gasm.core.enums.ComponentType;

/**
 * ...
 * @author Leo Bergman
 */
class MouseFollowerComponent extends Component {

    public function new() {
        componentType = ComponentType.Actor;
    }

    override public function update(dt:Float) {
        var model = owner.get(SpriteModelComponent);
        model.x = model.stageMouseX - (model.width / 2);
        model.y = model.stageMouseY - (model.height / 2);
    }
}