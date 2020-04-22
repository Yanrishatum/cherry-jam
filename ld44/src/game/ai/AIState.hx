package game.ai;

import hxd.Direction;
import owlbt.core.Decorator;
import owlbt.core.Node;
import owlbt.core.Data;
import owlbt.OwlContext;
import game.ai.decorators.*;
import game.ai.nodes.*;

class AIState
{
  
  
  public static function resolveNode(node:OwlbtNode):Node<AIState>
  {
    if (node.properties == null) node.properties = cast new Array<OwlbtProperty>();
    switch (node.type.toLowerCase())
    {
      case "engine":
        return new EngineModeNode(node.properties.getFloat("Power", 100));
      case "ability":
        return new AbilityUseNode(node.properties.get("Ability", ""));
      case "result":
        return new ResultNode(node.properties.getString("Result", "Success"));
    }
    return null;
  }
  
  public static function resolveDecorator(node:OwlbtDecorator):Decorator<AIState>
  {
    if (node.properties == null) node.properties = cast new Array<OwlbtProperty>();
    switch (node.type.toLowerCase())
    {
      case "distance to others":
        return new OthersDistance(node.properties.getString("Op", "<"), node.properties.getFloat("Distance", 200), node.properties.getString("Target", "nearest"));
      case "ability cooldown":
        return new AbilityState(node.properties.get("Ability", ""), node.properties.getFloat("State", 100));
      case "has ability?":
        return new HasAbility(node.properties.get("Ability", ""));
      case "hp check":
        return new HpCheck(node.properties.getFloat("HP", 50));
      case "race place":
        return new RacePlaceDec(node.properties.getInt("Place"));
    }
    return null;
  }
  
  public var car:Car;
  public var context:OwlContext<AIState>;
  public var race:RaceState;
  
  public var engine:Float = 0;
  public var steer:Float = 0;
  
  public function new(car:Car, context:OwlContext<AIState>)
  {
    this.car = car;
    this.context = context;
  }
  
}