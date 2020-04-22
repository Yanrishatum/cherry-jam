package game.abilities;

import hxd.Res;
import h2d.Bitmap;
import hxd.Math;
import hxd.Timer;
import h2d.RenderContext;
import game.Physics;
import differ.shapes.Circle;

class Skull extends Ability {
  
  public function new()
  {
    super(Data.skills.get(friendly_skull));
  }
  
  override private function _evaluate(c:Car)
  {
    var step = Math.PI * 2 / 3;
    var init = Math.random(Math.PI);
    new LeSkull(c, ref.data2, init);
    new LeSkull(c, ref.data2, init+step);
    new LeSkull(c, ref.data2, init+step+step);
  }
  
}

class LeSkull extends RouteTrigger
{
  
  var c:Car;
  var angle:Float;
  var d:Float;
  
  public function new(c:Car, d:Float, a:Float)
  {
    super(new Circle(c.x, c.y, 30), null, null);
    new Bitmap(Res.icons.item_skull.toTile().center(), this);
    this.angle = a;
    this.c = c;
    this.d = d;
    c.parent.addChildAt(this, 4);
  }
  
  override private function sync(ctx:RenderContext)
  {
    angle += Timer.dt * 4;
    poly.x = this.x = c.x + Math.cos(angle) * 120;
    poly.y = this.y = c.y + Math.sin(angle) * 120;
    super.sync(ctx);
  }
  
  override private function enter(s:PhysicsShape<Any>)
  {
    if (s.owner != c)
    {
      var c:Car = cast s.owner;
      c.damage(d);
      remove();
    }
    super.enter(s);
  }
  
}