package game.ai.decorators;

import hxd.Timer;
import owlbt.core.Decorator;

class AbilityState extends Decorator<AIState> {
  
  var ab:String;
  var state:Float;
  
  public function new(ab:String, state:Float)
  {
    this.ab = ab;
    this.state = state / 100;
  }
  
  override public function evaluate(ctx:AIState):Bool
  {
    // TODO
    for (a in ctx.car.abilities)
    {
      if (a.ref.id.toString() == ab)
      {
        var casted = Timer.lastTimeStamp - a.lastCast;
        casted = casted / a.ref.data;
        return casted > state;
      }
    }
    return false;
  }
  
}