package game;
import hxd.Math;
import hxd.Timer;
import h2d.Graphics;

class Ability {
  
  public var ref:Skills;
  public var lastCast:Float;
  
  public function cooldownVal():Float
  {
    var v = (Timer.lastTimeStamp - lastCast) / ref.cooldown;
    if (v < 0) v = 0;
    else if (v > 1) v = 1;
    return v;
  }
  
  public function new(ref:Skills) {
    this.ref = ref;
    lastCast = Timer.lastTimeStamp;
  }
  
  public function activate(c:Car):Bool
  {
    var ts = Timer.lastTimeStamp;
    if (lastCast + ref.cooldown < ts)
    {
      lastCast = ts;
      _evaluate(c);
      return true;
    }
    return false;
  }
  
  function _evaluate(c:Car)
  {
    
  }
  
}