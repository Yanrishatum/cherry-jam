package game.abilities;

import game.Physics;
import hxd.Res;
import h2d.Bitmap;
import hxd.Math;
import differ.shapes.Polygon;
import hxd.Timer;
import h2d.RenderContext;
import h2d.Object;

class Sword extends Ability {
  
  public function new()
  {
    super(Data.skills.get(unholy_sword));
  }
  
  override private function _evaluate(c:Car)
  {
    new SwordImpl(c, ref.data, ref.data2);
  }
  
}

class SwordImpl extends RouteTrigger {
  
  var car:Car;
  var duration:Float;
  var damage:Float;
  var ang:Float;
  
  public function new(c:Car, duration:Float, damage:Float)
  {
    super(Polygon.rectangle(17 - 75, 31 - 369, 120, 325, false), null, null);
    var b = new Bitmap(Res.effects.emo_sword.toTile(), this);
    b.setPosition(-75, -b.tile.height);
    ang = Math.random() * Math.PI * 2;
    this.car = c;
    this.duration = duration;
    this.damage = damage;
    c.parent.addChildAt(this, 4);
  }
  
  override private function sync(ctx:RenderContext)
  {
    ang += Timer.dt * 4;
    poly.x = this.x = Math.cos(ang) * 100 + car.x;
    poly.y = this.y = Math.sin(ang) * 100 + car.y;
    poly.rotation = Math.radToDeg(ang);
    rotation = ang;
    duration -= Timer.dt;
    if (duration < 0)
      remove();
    super.sync(ctx);
  }
  
  override private function enter(s:PhysicsShape<Any>)
  {
    if (s.owner != car)
      cast(s.owner, Car).damage(damage);
    super.enter(s);
  }
  
}