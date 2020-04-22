package game.ai.nodes;

import owlbt.core.Result;
import owlbt.core.Node;

class ResultNode extends Node<AIState> {
  
  var res:Result;
  
  public function new(result:String)
  {
    res = switch(result)
    {
      case "Failure": Failure;
      case "Running": Running;
      default: Success;
    }
  }
  
  override public function evaluate(ctx:AIState):Result
  {
    return res;
  }
  
}