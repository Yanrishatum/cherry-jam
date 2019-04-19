package gasm.core;
import gasm.core.enums.ComponentType;
import gasm.core.enums.SystemType;
import haxe.EnumFlags;

/**
 * @author Leo Bergman
 */
interface ISystem {
    var type(default, null):SystemType;
    var componentFlags(default, null):EnumFlags<ComponentType>;
    function update(comp:Component, delta:Float):Void;
}