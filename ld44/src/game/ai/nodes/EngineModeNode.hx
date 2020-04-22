package game.ai.nodes;

import owlbt.core.Result;
import owlbt.core.Node;

class EngineModeNode extends Node<AIState> {
  
  var speed:Float;
  
  public function new(speed:Float)
  {
    this.speed = speed / 100;
  }
  
  override public function evaluate(ctx:AIState):Result
  {
    ctx.engine = speed;
    return Success;
  }
  
}