package game.abilities;

class Bouncy extends Ability {
  
  public function new()
  {
    super(Data.skills.get(bouncy));
    
  }
  
  override private function _evaluate(c:Car)
  {
    c.ramProtection = true;
    new game.abilities.Sparkly.Circler(c, hxd.Res.icons.item_ball.toTile(), ref.data, enableColls);
    super._evaluate(c);
  }
  
  function enableColls(car:Car)
  {
    car.ramProtection = false;
  }
  
}