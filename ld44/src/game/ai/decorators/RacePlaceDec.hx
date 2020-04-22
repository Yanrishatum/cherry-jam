package game.ai.decorators;

import owlbt.core.Decorator;

class RacePlaceDec extends Decorator<AIState> {
  
  public var place:Int;
  
  public function new(place:Int)
  {
    this.place = place;
  }
  
  override public function evaluate(ctx:AIState):Bool
  {
    var place = 1;
    var pos = ctx.car.position;
    for (c in ctx.race.cars)
    {
      if (c != ctx.car && c.position > pos) place--;
    }
    return place == this.place;
  }
  
}