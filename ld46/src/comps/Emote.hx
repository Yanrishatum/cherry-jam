package comps;

import State;
import hxd.Timer;
import h2d.RenderContext;
import h2d.Bitmap;
import h2d.Object;

class Emote extends Object {
  
  var shake:Bool;
  var t:Float;
  
  public function new(index:EmoteIndex, flip:Bool, ?parent) {
    super(parent);
    var bg = new Bitmap(R.a.sub(128, 55, 28, 24), this);
    var ico = new Bitmap(R.a.sub(157 + 23 * (index % 8), 55 + 15 * Std.int(index / 8), 22, 14, 3, 3), this);
    if (flip) {
      bg.tile.flipX();
      ico.tile.dx -= bg.tile.width;
    }
    bg.tile.dy -= bg.height;
    ico.tile.dy -= bg.height;
    this.alpha = 0;
    shake = (index:Int) > 10;
    if (index == Feeble && State.i.flags.get(Sick) == 0) shake = false;
    t = Timer.lastTimeStamp + 3;
  }
  
  override function sync(ctx:RenderContext)
  {
    if (visible) {
      if (Timer.lastTimeStamp > t) {
        alpha -= Timer.dt * 2;
        this.y -= Timer.dt * 10;
        if (alpha < 0) {
          alpha = 0;
          remove();
        }
      } else {
        if (alpha < 1) {
          alpha += Timer.dt * 2;
          this.y -= Timer.dt * 10;
          if (alpha > 1) alpha = 1;
        }
      }
      if (shake) {
        var sx = hxd.Math.random(1) - .5;
        var sy = hxd.Math.random(1) - .5;
        for (c in children) c.setPosition(sx, sy);
      }
    }
    super.sync(ctx);
  }
  
}