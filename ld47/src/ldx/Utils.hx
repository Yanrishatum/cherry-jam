package ldx;

import h2d.Tile;
import h3d.mat.Data;
import h3d.mat.Texture;
import haxe.MainLoop;

class Utils {
  
  static var bgLoopEvent:MainEvent;
  static var bgStart:Int = -1;
  static var bgCur:Int;
  static var bgTarget:Int;
  static var bgTime:Float;
  
  public static function bgColor(color:Int) {
    bgCur = bgStart = State.engine.backgroundColor;
    bgTarget = 0xff000000 | color;
    bgTime = 0;
    if (bgLoopEvent == null) bgLoopEvent = MainLoop.add(bgUpdate);
  }
  
  static function bgUpdate() {
    bgTime += hxd.Timer.dt * 2;
    if (bgTime >= 1) bgCur = bgTarget;
    else {
      bgCur = 0xff000000 | hxd.Math.colorLerp(bgStart, bgTarget, bgTime);
    }
    State.engine.backgroundColor = bgCur;
    #if js
    js.Browser.document.body.style.backgroundColor = "#" + StringTools.hex(bgCur & 0xffffff, 6) + 'ff';
    #end
    if (bgCur == bgTarget) {
      bgLoopEvent.stop();
      bgLoopEvent = null;
    }
  }
  
  public static inline function allocSDFTile(w:Int, h:Int, color:Int, alpha:Float = 1) {
    return Tile.fromTexture(allocSDFTexture(w, h, color, alpha));
  }
  
  static var sdfCache:Map<Int, Array<Texture>> = [];
  public static function allocSDFTexture(w:Int, h:Int, color:Int, alpha:Float = 1, ?flags:Array<TextureFlags>):Texture {
    var key = (color & 0xffffff) | (Math.round(alpha * 0xff) & 0xff) << 24;
    var cache = sdfCache.get(key);
    if (cache == null) {
      cache = [];
      sdfCache.set(key, cache);
    } else {
      for (tex in cache) {
        if (tex.width == w && tex.height == h) return tex;
      }
    }
    var tex = new Texture(w, h, flags);
    tex.clear(color, alpha);
    tex.realloc = () -> tex.clear(color, alpha);
    cache.push(tex);
    return tex;
  }
  
}