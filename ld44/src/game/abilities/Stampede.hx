package game.abilities;

import hxd.Math;
import hxd.Timer;
import h2d.RenderContext;
import hxd.Res;
import h2d.Anim;
import game.Physics;
import differ.shapes.Polygon;

class Stampede extends Ability {
  
  public function new()
  {
    super(Data.skills.get(stampede));
  }
  
  override private function _evaluate(c:Car)
  {
    super._evaluate(c);
    new Horse(c, 150, -80, ref.data);
    new Horse(c, -150, -80, ref.data);
    new Horse(c, 300, -160, ref.data);
    new Horse(c, -300, -160, ref.data);
  }
  
}

class Horse extends RouteTrigger {
  
  var car:Car;
  var offX:Float;
  var offY:Float;
  var duration:Float;
  
  public function new(c:Car, offX:Float, offY:Float, duration:Float)
  {
    this.car = c;
    this.offX = offX;
    this.offY = offY;
    this.duration = duration;
    super(Polygon.rectangle(0, 0, 78, 240), null, null);
    var anim = new Anim(Res.effects.rider_wildhorse_4pcs_361x361.toTile().split(4), 30, this);
    anim.x = -360 / 2;
    anim.y = -360 / 2;
    c.parent.addChildAt(this, 4);
  }
  
  override public function check(s:PhysicsShape<Any>)
  {
    if (s.owner != car)
    {
      var c = s.getColl();
      var o = cast(s.owner, Car);
      s.shape.x += c.separationX * .2;
      s.shape.y += c.separationY * .2;
    }
    super.check(s);
  }
  
  override private function sync(ctx:RenderContext)
  {
    var c = Math.cos(car.rotation);
    var s = Math.sin(car.rotation);
    this.x = poly.x = car.x + offX * c + offY * s;
    this.y = poly.y = car.y + offX * s + offY * -c;
    this.rotation = car.rotation;
    poly.rotation = Math.radToDeg(rotation);
    duration -= Timer.dt;
    if (duration <= 0) remove();
    super.sync(ctx);
  }
  
}