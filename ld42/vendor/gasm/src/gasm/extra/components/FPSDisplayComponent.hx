package gasm.extra.components;
import gasm.core.Component;
import gasm.core.components.TextModelComponent;
import gasm.core.enums.ComponentType;

/**
 * ...
 * @author Leo Bergman
 */
class FPSDisplayComponent extends Component {

    public function new() {
        componentType = ComponentType.Actor;
    }

    override public function update(delta:Float) {
        var model = owner.get(TextModelComponent);
        var fps = owner.get(FPSComponent);
        model.text = Std.string(fps.fps);
    }

}