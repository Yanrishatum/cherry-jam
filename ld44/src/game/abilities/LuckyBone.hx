package game.abilities;

import game.Physics;
import differ.shapes.Circle;
import hxd.Res;
import hxd.Timer;
import hxd.Math;
import h2d.RenderContext;
import h2d.Bitmap;
import h2d.Tile;
import h2d.Object;

class LuckyBone extends Ability {
  
  public function new()
  {
    super(Data.skills.get(lucky_bone));
  }
  
  override private function _evaluate(c:Car)
  {
    var p = c.race.carAtPlace(c.race.carPlace(c) - 1);
    if (p == c) p = c.race.carAtPlace(1000);
    new Chaser(c, Res.icons.item_bone.toTile(), p, c.angle, ref.data2);
    // super._evaluate(c);
  }
  
}

class Chaser extends RouteTrigger {
  
  var angle:Float;
  var target:Car;
  var damage:Float;
  
  public function new(c:Car, g:Tile, target:Car, angle:Float, damage:Float)
  {
    super(new Circle(c.x, c.y, 30), null, null);
    this.damage = damage;
    new Bitmap(g.center(), this);
    this.target = target;
    this.angle = angle;
    c.parent.addChildAt(this, 4);
  }
  
  override private function sync(ctx:RenderContext)
  {
    children[0].rotation += Timer.dt * 8;
    var speed = Math.max(2000, this.target.velocity * 1.5) * Timer.dt;
    var ta = Math.atan2(target.y - y, target.x - x);
    this.angle = Math.angleLerp(angle, ta, Timer.dt * 8);
    poly.x += Math.cos(angle) * speed;
    poly.y += Math.sin(angle) * speed;
    this.x = poly.x;
    this.y = poly.y;
    super.sync(ctx);
  }
  
  override private function enter(s:PhysicsShape<Any>)
  {
    if (s.owner == target)
    {
      target.damage(damage);
      target.angle += Math.random(2) - 1.0;
      remove();
    }
    super.enter(s);
  }
  
}