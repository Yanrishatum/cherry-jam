package game.abilities;

class Teddy extends Ability {
  
  public function new()
  {
    super(Data.skills.get(teddy));
    
  }
  
  override private function _evaluate(c:Car)
  {
    c.stats.bonusDecl = ref.data2;
    new game.abilities.Sparkly.Circler(c, hxd.Res.icons.item_teddy.toTile(), ref.data, enableColls);
    super._evaluate(c);
  }
  
  function enableColls(car:Car)
  {
    car.stats.bonusDecl = 0;
  }
  
}