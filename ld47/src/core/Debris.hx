package core;

import h2d.Bitmap;
import hxd.Res;
import differ.shapes.Polygon;
import format.tmx.Data;

class Debris extends Trigger {
  
  public var hitbox:Polygon;
  
  public function new(ref:TmxObject, ?parent) {
    super(ref, parent);
    hitbox = collider;
    var b = hitbox.bounds();
    final extent = 25;
    b.extent(extent);
    collider = new Polygon(x, y, [
      new differ.math.Vector(b.xMin, b.yMin),
      new differ.math.Vector(b.xMax, b.yMin),
      new differ.math.Vector(b.xMax, b.yMax),
      new differ.math.Vector(b.xMin, b.yMax),
    ]);
    damage = 0;
    decay = 0;
    decayAfterRepair = false;
    var t;
    if (ref.properties.getBool("small")) {
      t = Res.debris_small.toTile();
      t.dx = -47;
      t.dy = -51;
    }
    else {
      t = Res.debris.toTile().center();
      t.dx = -60;
      t.dy = -66;
    }
    var bt = new Bitmap(t, this);
    bt.x = Math.round((b.xMax - b.xMin) / 2) - extent;
    bt.y = (b.yMax - b.yMin) / 2 - extent;
    makeOutline();
  }
  
  override public function reset()
  {
    super.reset();
    hp = 0;
    canDecay = false;
  }
  
}