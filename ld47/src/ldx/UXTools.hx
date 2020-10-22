package ldx;

import h2d.Object;
import hxd.snd.SoundGroup;
import hxd.res.Sound;
import ch2.Animation;
import h2d.col.Bounds;
import differ.shapes.Polygon;
import h2d.Tile;

class UXTools {
  
  public static function sfx(s:Sound, loop:Bool = false, volume:Float = 1, ?group:SoundGroup) {
    return s.play(loop, volume, R.sfx, group);
  }
  
  static inline var dist:Float = 500 * 500;
  public static function relSFX(s:Sound, to:Object, loop:Bool = false, volume:Float = 1, ?group:SoundGroup) {
    var vol = hxd.Math.clamp(1 - hxd.Math.distanceSq(to.x - State.game.player.vx, to.y - State.game.player.vy) / dist, 0.2, 1);
    return sfx(s, loop, volume * vol, group);
  }
  
  public static function xsub(a:Tile, x:Int, y:Int, w:Int, h:Int, count:Int, sx:Int = 1, dx:Float=0, dy:Float=0) {
    sx += w;
    return [for (i in 0...count) a.sub(x + i * sx, y, w, h, dx, dy)];
  }
  
  public static function ysub(a:Tile,x:Int, y:Int, w:Int, h:Int, count:Int, sy:Int = 1, dx:Float=0, dy:Float=0) {
    sy += h;
    return [for (i in 0...count) a.sub(x, y + i * sy, w, h, dx, dy)];
  }
  
  public static inline function bounds(p:Polygon) {
    var b = new Bounds();
    for (pt in p.vertices) {
      if (b.xMin > pt.x) b.xMin = pt.x;
      if (b.xMax < pt.x) b.xMax = pt.x;
      if (b.yMin > pt.y) b.yMin = pt.y;
      if (b.yMax < pt.y) b.yMax = pt.y;
    }
    return b;
  }
  public static inline function extent(b:Bounds, e:Float) {
    b.xMin -= e;
    b.xMax += e;
    b.yMin -= e;
    b.yMax += e;
  }
  
  public static inline function frame(t:Tile, d:Float) {
    return new AnimationFrame(t, d);
  }
}