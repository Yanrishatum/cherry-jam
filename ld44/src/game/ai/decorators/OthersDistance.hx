package game.ai.decorators;

import owlbt.core.Decorator;

class OthersDistance extends Decorator<AIState> {
  
  var op:Operation;
  var dist:Float;
  var who:String;
  
  public function new(op:String, distance:Float, who:String)
  {
    this.op = switch (op)
    {
      case "=": OpEq;
      case "!=": OpNeq;
      case ">": OpGreaterThan;
      case "<": OpLessThan;
      case ">=": OpGreaterEquals;
      case "<=": OpLessEquals;
      default: OpLessThan;
    }
    dist = distance;
  }
  
  override public function evaluate(ctx:AIState):Bool
  {
    var closest = ctx.race.carSelector(who, ctx.car).dist;
    var result = switch (op) {
      case OpEq: closest == dist;
      case OpNeq: closest != dist;
      case OpLessThan: closest < dist;
      case OpGreaterThan: closest > dist;
      case OpGreaterEquals: closest >= dist;
      case OpLessEquals: closest <= dist;
    };
    return result;
  }
  
}

enum CarTarget
{
  
}

enum Operation
{
  OpEq;
  OpNeq;
  OpLessThan;
  OpGreaterThan;
  OpLessEquals;
  OpGreaterEquals;
}