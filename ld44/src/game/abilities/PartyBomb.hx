package game.abilities;

import hxd.Res;

class PartyBomb extends Ability {
  
  public function new()
  {
    super(Data.skills.get(party_bomb));
  }
  
  override private function _evaluate(c:Car)
  {
    var p = c.race.carAtPlace(c.race.carPlace(c) + 1);
    if (p == c) p = c.race.carAtPlace(1);
    new game.abilities.LuckyBone.Chaser(c, Res.icons.item_bomb.toTile(), p, Math.PI + c.angle, ref.data2);
    // super._evaluate(c);
  }
  
}