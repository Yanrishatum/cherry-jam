package game.ai.decorators;

import owlbt.core.Decorator;

class HasAbility extends Decorator<AIState> {
  
  var ability:String;
  
  public function new(name:String)
  {
    this.ability = name;
  }
  
  override public function evaluate(ctx:AIState):Bool
  {
    for (a in ctx.car.abilities)
    {
      if (a.ref.id.toString() == ability) return true;
    }
    return false;
  }
  
}