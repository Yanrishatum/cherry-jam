package game.abilities;

import hxd.Res;
import hxd.Timer;
import game.Physics;
import hxd.Math;
import h2d.RenderContext;
import differ.shapes.Polygon;

class HighStakes extends Ability {
  
  public function new()
  {
    super(Data.skills.get(high_stakes));
  }
  
  override private function _evaluate(c:Car)
  {
    var off = Math.PI / 16;
    new Stake(c, c.angle, ref.data2);
    for (i in 1...8)
    {
      new Stake(c, c.angle + off * i, ref.data2);
      new Stake(c, c.angle - off * i, ref.data2);
    }
    super._evaluate(c);
  }
  
}

class Stake extends RouteTrigger {
  
  var car:Car;
  var angle:Float;
  var damage:Float;
  var dist:Float;
  
  public function new(car:Car, angle:Float, damage:Float)
  {
    this.car = car;
    this.angle = angle;
    this.damage = damage;
    super(Polygon.rectangle(0, 0, 36, 138), null, null);
    new h2d.Bitmap(Res.effects.stoker_stake.toTile(), this).rotation = angle + Math.PI*.5;
    // rotation = angle;
    this.x = poly.x = car.x + Math.cos(angle) * 50;
    this.x = poly.y = car.y + Math.sin(angle) * 50;
    poly.rotation = Math.radToDeg(angle);
    car.parent.addChildAt(this, 4);
  }
  
  override private function enter(s:PhysicsShape<Any>)
  {
    if (s.owner != car)
    {
      cast(s.owner, Car).damage(damage);
      remove();
    }
    super.enter(s);
  }
  
  override private function sync(ctx:RenderContext)
  {
    final speed = 3000;
    this.x = poly.x += Math.cos(angle) * speed * Timer.dt;
    this.y = poly.y += Math.sin(angle) * speed * Timer.dt;
    dist += Timer.dt * speed;
    if (dist > 6000) remove();
    super.sync(ctx);
  }
  
}