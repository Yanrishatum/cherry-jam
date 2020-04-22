package game.abilities;

import hxd.Timer;
import hxd.Res;
import h2d.Bitmap;
import h2d.RenderContext;
import h2d.Object;

class Armor extends Ability {
  
  public function new()
  {
    super(Data.skills.get(hyper_armor));
  }
  
  override private function _evaluate(c:Car)
  {
    new ArmorView(c, ref.data);
  }
  
}

class ArmorView extends Object
{
  
  var duration:Float;
  var car:Car;
  var balls:Array<Bitmap>;
  
  public function new (c:Car, duration:Float)
  {
    super(c);
    car = c;
    this.duration = duration;
    var t = Res.effects.blood_ball.toTile().center();
    balls = [
      for (i in 0...14) new Bitmap(t, this)
    ];
    c.invulnerable = true;
  }
  
  override private function sync(ctx:RenderContext)
  {
    var rot = Timer.lastTimeStamp * 5;
    var step = balls.length / (Math.PI * 2);
    for (b in balls)
    {
      b.x = Math.cos(rot) * 90;
      b.y = Math.sin(rot) * 90;
      rot += step;
    }
    duration -= Timer.dt;
    if (duration < 0)
    {
      car.invulnerable = false;
      remove();
    }
    super.sync(ctx);
  }
  
}