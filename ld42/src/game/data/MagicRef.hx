package game.data;

import engine.HXP;
import game.comps.Character;
import game.comps.MapHex;
import game.data.MagicTarget;

class MagicRef
{
  public var type:HexType;
  public var name:String;
  public var cost:String;
  public var damage:Float;
  public var extraTiles:Array<TileMovement>;
  public var target:MagicTarget;
  public var extraAction:MapHex->Void;
  
  public var isAi:Bool;
  public var cooldown:Int;
  public var targets:Int;
  public var initialCD:Int;
  
  public var currCD:Int;
  
  public function new(data:MagicRefJson)
  {
    this.name = data.id;
    isAi = data.type == "AI";
    this.damage = data.damage;
    this.target = data.target;
    if (isAi)
    {
      this.cooldown = data.cooldown;
      this.targets = data.count;
      this.initialCD = currCD = data.start;
      
    }
    else
    {
      this.type = HexType.createByName(data.type);
      this.extraTiles = new Array();
      this.cost = data.cost;
      for (dir in data.extra_tiles)
      {
        if (Std.is(dir, Array))
        {
          extraTiles.push(dir);
        }
        else 
        {
          extraTiles.push([dir]);
        }
      }
      if (data.extra_action != null)
      {
        var act:String = data.extra_action;
        if (StringTools.startsWith(act, "#swap:"))
        {
          swap = HexType.createByName(act.substr(6));
          if (swap == null) throw "Invalid hex type: " + act;
          extraAction = swapTile;
        }
      }
    }
  }
  
  public function apply(battle:BattleScene):Void
  {
    
    switch(target)
    {
      case Boss:
        battle.boss.damage(damage, type);
      case Party:
        // TODO: Pick member
        var arr = battle.chars.filter((c:Character) -> c.hp > 0);
        var min:Character = arr[0];
        for (c in arr)
        {
          if (c.hp < min.hp)
          {
            min = c;
          }
        }
        if (min != null) min.damage(damage, type);
      case PartyAll: // CHARACTER
        for (p in battle.chars)
        {
          p.damage(damage, type);
        }
      case PartyRandom:
        var chars:Array<Character> = battle.chars.filter((c:Character) -> c.hp > 0);
        var i:Int = HXP.min(targets, chars.length);
        while (i-- > 0)
        {
          var char:Character = chars[HXP.randomIZ(chars.length)];
          char.damage(damage, HexType.Wastelands);
          chars.remove(char);
        }
    }
    
  }
  
  private var swap:HexType;
  private function swapTile(tile:MapHex):Void
  {
    tile.swap(swap);
  }
}

typedef MagicRefJson =
{
  var id:String;
  var type:String;
  var cost:String;
  var damage:Float;
  var target:String;
  var extra_tiles:Array<Dynamic>;
  var extra_action:String;
  var cooldown:Int;
  var count:Int;
  var start:Int;
}

typedef TileMovement = Array<Int>;
