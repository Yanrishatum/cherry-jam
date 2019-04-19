package gasm.core.utils.texture;

typedef TextureFrame = {
    frame:{ x:Int, y:Int, w:Int, h:Int },
    pivot:{ x:Float, y:Float },
    rotated:Bool,
    sourceSize:{ w:Int, h:Int },
    spriteSourceSize:{ x:Int, y:Int, w:Int, h:Int },
    trimmed:Bool,
}
