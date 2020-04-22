package game.abilities;

import h2d.Bitmap;
import hxd.Math;
import hxd.Timer;
import h2d.RenderContext;
import h2d.Object;
import hxd.Res;
import h2d.Tile;

class Healing extends Ability {
  
  public function new(ref:Skills)
  {
    super(ref);
    // var icon:Tile = Res.load(ref.icon).toTile();
  }
  
  override private function _evaluate(c:Car)
  {
    c.hp += ref.data2 * c.stats.hpPool;
    if (c.hp > c.hpMax) c.hp = c.hpMax;
    new HealingEff(c, Res.load(ref.icon).toTile());
  }
  
}

class HealingEff extends Object
{
  var timer:Float = 2;
  var c:Car;
  public function new(c:Car, icon:Tile)
  {
    super();
    this.c = c;
    c.parent.addChildAt(this, 4);
    new Bitmap(icon.center(), this);
    alpha = 0;
  }
  
  override private function sync(ctx:RenderContext)
  {
    y = c.y - 140 + Math.sin(Timer.lastTimeStamp * 4) * 10;
    x = c.x;
    timer -= Timer.dt;
    if (timer < 0)
    {
      alpha -= Timer.dt;
      if (alpha <= 0)
      {
        alpha = 0;
        remove();
      }
    }
    else if (alpha < 1)
    {
      alpha += Timer.dt * 4;
      if (alpha > 1) alpha = 1;
    }
    
    super.sync(ctx);
  }
  
}