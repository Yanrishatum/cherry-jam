package util;

import h2d.Object;
import h2d.Bitmap;
import h2d.Tile;

class Util {
  
  public static function makeShadow(t:Tile, p:Object, color:Int = 64):Bitmap
  {
    var b = new Bitmap(t, p);
    var s = new ShadowShader();
    s.color = color / 0xff;
    b.addShader(s);
    return b;
  }
  
}