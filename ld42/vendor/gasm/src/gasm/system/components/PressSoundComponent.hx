package gasm.system.components;
import gasm.core.components.SoundModelComponent;
import gasm.core.components.SpriteModelComponent;
import gasm.core.Component;
import gasm.core.enums.ComponentType;
import gasm.core.enums.EventType;
import gasm.core.events.InteractionEvent;

/**
 * ...
 * @author Leo Bergman
 */
class PressSoundComponent extends Component {

    public function new() {
        componentType = ComponentType.Sound;
    }

    override public function init() {
        var spriteModel = owner.get(SpriteModelComponent);
        var soundModel = owner.get(SoundModelComponent);
        spriteModel.addHandler(EventType.PRESS, function(e:InteractionEvent) {
            soundModel.pos = 0;
            soundModel.playing = true;
        });
    }
}