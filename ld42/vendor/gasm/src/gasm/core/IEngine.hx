package gasm.core;

/**
 * @author Leo Bergman
 */
interface IEngine {
    public var baseEntity(default, null):Entity;
    public function tick():Void;
}