package game.abilities;

import hxd.Math;
import hxd.Timer;
import haxe.Json;
import h2d.Particles;
import h2d.RenderContext;
import h2d.Object;
import util.Trail2D;

class Overdose extends Ability {
  
  public function new()
  {
    super(Data.skills.get(overdose));
  }
  
  override private function _evaluate(c:Car)
  {
    new OverdoseDisp(c, ref.data, ref.data2);
  }
  
}

class OverdoseDisp extends Object {
  
  var parts:Particles;
  var partsStart:Particles;
  
  var duration:Float;
  var car:Car;
  var power:Float;
  
  public function new(c:Car, duration:Float, power:Float)
  {
    super(c);
    this.y += 100;
    this.car = c;
    this.power = power;
    this.duration = duration;
    c.stats.bonusSpeed += power * 2;
    c.stats.bonusAccl += power;
    parts = new Particles(this);
    parts.load(Json.parse(hxd.Res.parts.bloodboost.entry.getText()), hxd.Res.parts.bloodboost.entry.path);
    partsStart = new Particles(this);
    partsStart.load(Json.parse(hxd.Res.parts.bloodboost_ignition.entry.getText()), hxd.Res.parts.bloodboost_ignition.entry.path);
    // for (g in parts.getGroups()) g.emitLoop = false;
    // for (g in partsStart.getGroups()) g.emitLoop = false;
    for (g in parts.getGroups())
    {
      // g.isRelative = false;
      g.emitLoop = false;
    }
    parts.onEnd = stopInit;
    partsStart.onEnd = stopInit;
    // for (g in partsStart.getGroups()) g.isRelative = false;
  }
  
  function stopInit()
  {
    
  }
  
  override private function sync(ctx:RenderContext)
  {
    duration -= Timer.dt;
    if (duration < 0)
    {
      alpha = Math.lerp(alpha, 0, Timer.dt);
      if (alpha < Math.EPSILON)
      {
        car.stats.bonusAccl -= power;
        car.stats.bonusSpeed -= power * 2;
        remove();
      }
    }
    super.sync(ctx);
  }
  
}