package gasm.core;
import gasm.core.enums.ComponentType;
import gasm.core.enums.SystemType;
import haxe.EnumFlags;

/**
 * ...
 * @author Leo Bergman
 */
class System {
    public var type(default, null):SystemType;
    public var componentFlags(default, null):EnumFlags<ComponentType>;

    public function new() {
        componentFlags = new EnumFlags<ComponentType>();
    }
}