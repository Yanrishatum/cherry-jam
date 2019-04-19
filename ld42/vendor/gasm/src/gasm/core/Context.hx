package gasm.core;

/**
 * ...
 * @author Leo Bergman
 */
interface Context {
    var baseEntity(get, null):Entity;
    var systems(default, null):Array<ISystem>;
}