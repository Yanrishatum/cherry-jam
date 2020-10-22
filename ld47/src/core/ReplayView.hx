package core;

import hxd.Res;
import h2d.Tile;
import h2d.TileGroup;
import h2d.Object;

class ReplayView extends Object {
  
  var replay:Replay;
  
  public function new(r:Replay, color:Int, ?parent) {
    super(parent);
    
    var t = Res.step.toTile();
    t.setCenterRatio(0.1);
    var t2 = t.clone();
    t2.flipX();
    var g = new TileGroup(t, this);
    var cnt = 0;
    var fl:Bool = true;
    var ang = Math.PI * .5;
    var prev = r.frames[0];
    for (f in r.frames) {
      if ((cnt++ % 6) == 0) {
        g.addTransform(f.px, f.py, 1, 1, ang, fl ? t : t2);
        // g.add(f.px, f.py, fl ? t : t2);
        fl = !fl;
      }
      ang = Math.atan2(f.py - prev.py, f.px - prev.px) + Math.PI * .5;
      prev = f;
    }
    g.color.setColor(0xff000000 | color);
    g.alpha = 0.7;
    // var s = new ldx.shader.SDFCircle();
    // g.addShader(s);
  }
  
}