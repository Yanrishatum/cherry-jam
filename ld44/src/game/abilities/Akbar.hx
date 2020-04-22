package game.abilities;

import hxd.Math;
import hxd.Timer;
import hxd.Res;
import h2d.Bitmap;
import h2d.RenderContext;
import differ.shapes.Circle;
import game.Physics;
import h2d.Object;

class Akbar extends Ability {
  
  public function new()
  {
    super(Data.skills.get(brazen_trap));
  }
  
  override private function _evaluate(c:Car)
  {
    super._evaluate(c);
    var ang = c.angle + Math.PI;
    var off = Math.degToRad(20);
    new AkbarImpl(c, ang, ref.data2);
    new AkbarImpl(c, ang+off, ref.data2);
    new AkbarImpl(c, ang-off, ref.data2);
  }
  
}

class AkbarImpl extends RouteTrigger
{
  
  var safe = 0.4;
  var damage:Float;
  var angle:Float;
  var open:Bool;
  var sprite:Bitmap;
  
  public function new(c:Car, angle:Float, damage:Float)
  {
    super(new Circle(c.x, c.y, 50), c.parent, null);
    this.damage = damage;
    sprite = new Bitmap(Res.effects.trap_trap_closed.toTile().center(), this);
    open = false;
    x = c.x;
    y = c.y;
    this.angle = angle;
  }
  
  override private function sync(ctx:RenderContext)
  {
    poly.x = this.x += Math.cos(angle) * safe * 40;
    poly.y = this.y += Math.sin(angle) * safe * 40;
    if (safe > 0)
    {
      safe -= Timer.dt;
      if (safe < 0) safe = 0;
    }
    if (open)
    {
      alpha -= Timer.dt;
      if (alpha <= 0)
      {
        alpha = 0;
        remove();
      }
    }
    super.sync(ctx);
  }
  
  override private function enter(s:PhysicsShape<Any>)
  {
    if (!open && safe <= 0)
    {
      cast(s.owner, Car).damage(damage);
      open = true;
      sprite.tile = Res.effects.trap_trap_opened.toTile().center();
    }
    super.enter(s);
  }
  
}