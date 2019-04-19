package gasm.core.components;

/**
 * Model to interface between different text backends.
 * Automatically added when you add ComponentType.TEXT to an Entity.
 * 
 * @author Leo Bergman
 */
class TextModelComponent extends SpriteModelComponent {
    public var text(default, default):String = "";
    public var font(default, default):Null<String>;
    public var size(default, default):Null<Int>;
    public var color(default, default):Null<Int>;
    public var selectable(default, default):Bool = false;

    public function new(text:String = "", size:Int = 14, col:UInt = 0xFFFFFF) {
        super();
        this.text = text;
        this.size = size;
        this.color = col;
    }
}