package game.abilities;

import h2d.Tile;
import hxd.Math;
import hxd.Timer;
import h2d.RenderContext;
import hxd.Res;
import h2d.Object;
import h2d.Bitmap;

class Sparkly extends Ability {
  
  public function new() {
    super(Data.skills.get(sparkly));
  }
  
  override private function _evaluate(c:Car)
  {
    c.shape.collideDynamics = false;
    new Circler(c, Res.icons.item_ghostie.toTile(), ref.data, enableColls);
    super._evaluate(c);
  }
  
  function enableColls(car:Car)
  {
    car.shape.collideDynamics = true;
  }
  
}

class Circler extends Object
{
  
  var ghosts:Array<Bitmap>;
  var duration:Float = 4;
  var car:Car;
  var onEnd:Car->Void;
  
  public function new(p:Car, g:Tile, duration:Float, onEnd:Car->Void)
  {
    super(p);
    g.setCenterRatio();
    ghosts = [
      new Bitmap(g, this),
      new Bitmap(g, this),
      new Bitmap(g, this)
    ];
    for (g in ghosts) g.rotation = Math.random(Math.PI * 2);
    this.duration = duration;
    this.onEnd = onEnd;
    car = p;
    this.alpha = 0;
  }
  
  override private function sync(ctx:RenderContext)
  {
    var step = Math.PI * 2 / ghosts.length;
    var an = Timer.lastTimeStamp*3;
    for (g in ghosts)
    {
      g.setPosition(Math.cos(an) * 100, Math.sin(an) * 100);
      an += step;
    }
    if (duration > 0)
    {
      duration -= Timer.dt;
      alpha = Math.lerp(alpha, 1, 4 * Timer.dt);
      if (duration <= 0) onEnd(car);
    }
    else 
    {
      alpha = Math.lerp(alpha, 0, 4 * Timer.dt);
      if (alpha < Math.EPSILON)
      {
        remove();
      }
    }
    super.sync(ctx);
  }
  
}