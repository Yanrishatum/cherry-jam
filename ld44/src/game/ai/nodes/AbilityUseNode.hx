package game.ai.nodes;

import owlbt.core.Result;
import owlbt.core.Node;

class AbilityUseNode extends Node<AIState> {
  
  var ab:String;
  
  public function new(ability:String)
  {
    this.ab = ability;
  }
  
  override public function evaluate(ctx:AIState):Result
  {
    for (a in ctx.car.abilities)
    {
      if (a.ref.name.toString() == ab)
      {
        if (a.activate(ctx.car))
          return Success;
      }
    }
    return Failure;
  }
  
}