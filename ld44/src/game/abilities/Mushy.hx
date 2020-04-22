package game.abilities;


class Mushy extends Ability {
  
  public function new()
  {
    super(Data.skills.get(mushy));
    
  }
  
  override private function _evaluate(c:Car)
  {
    c.stats.bonusAccl += ref.data2;
    new game.abilities.Sparkly.Circler(c, hxd.Res.icons.item_brain.toTile(), ref.data, enableColls);
    super._evaluate(c);
  }
  
  function enableColls(car:Car)
  {
    car.stats.bonusAccl -= ref.data2;
  }
  
}