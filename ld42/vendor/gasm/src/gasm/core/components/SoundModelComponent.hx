package gasm.core.components;

import gasm.core.Component;
import gasm.core.enums.ComponentType;

/**
 * Model to interface between different sound backends.
 * Automatically added when you add ComponentType.SOUND to an Entity.
 * 
 * @author Leo Bergman
 */
class SoundModelComponent extends Component {
    public var volume(default, default):Float;
    public var pan(default, default):Float;
    public var pos(default, default):Float;
    public var playing(default, default):Bool;

    public function new() {
        componentType = ComponentType.SoundModel;
    }

}