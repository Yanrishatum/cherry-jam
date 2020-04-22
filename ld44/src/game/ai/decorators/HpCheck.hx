package game.ai.decorators;

import owlbt.core.Decorator;

class HpCheck extends Decorator<AIState> {
  
  var value:Float;
  
  public function new(value:Float)
  {
    this.value = value / 100;
  }
  
  override public function evaluate(ctx:AIState):Bool
  {
    return (ctx.car.hp / ctx.car.hpMax >= value);
  }
  
}