package ld45;

import hxd.Key;
import hxd.Res;

class State
{
  
  public static var food:Int = 0;
  public static var water:Int = 0;
  public static var clothing:Int = 0;
  public static var instruments:Int = 0;
  public static var humans:Int = 0;
  public static var hunger:Int = 0;
  
  public static var ui:UI;
  public static var viewDist:Int = 1;
  
  public static var config:BalanceConfig;
  
  public static function start()
  {
    viewDist = 1;
    food = 0;
    water = 0;
    clothing = 0;
    instruments = 0;
    humans = 1;
    hunger = 0;
    ui.visible = true;
    GameMap.current.start();
    ui.step();
  }
  
  public static function camp()
  {
    SoundSystem.play(Res.sfx.ld_sfx_collect);
    instruments -= Math.ceil(humans * config.camp_cost);
    var t = GameMap.current.findTile(GameMap.current.player.pos);
    if (t.resource != -1)
    {
      gather(t.type, t.resource);
      t.resource = -1;
    }
    if (t.quest == 1)
    {
      GameMap.current.event.show(t.type);
      t.quest = -1;
    }
    t.updateIcon();
    for (n in t.neighbors)
    {
      if (n.resource != -1)
      {
        gather(n.type, n.resource);
        n.resource = -1;
      }
      if (n.quest == 1)
      {
        GameMap.current.event.show(n.type);
        n.quest = -1;
      }
      n.updateIcon();
    }
    step();
  }
  
  public static function gainAmount(initial:Int)
  {
    
    return initial + Math.ceil(initial * config.gatherPerPeson * humans - 1);
    // return initial + Math.ceil(initial * Math.pow(config.gatherPerPeson, humans - 1));
  }
  
  public static function gather(tile:TileType, resource:Int)
  {
    var info:TileBalance = Reflect.field(config.tiles, tile.getName());
    for (res in info.gather)
    {
      gain(res);
    }
  }
  
  public static inline function maxCarry() return humans * 30 + 10;
  
  public static function gain(res:Array<Dynamic>)
  {
    var amount = gainAmount((res[1]:Int));
    switch((res[0]:String))
    {
      case "food":
        food += amount;
        if (food < 0) food = 0;
      case "water":
        water += amount;
        if (water < 0) water = 0;
      case "clothing":
        clothing += amount;
        if (clothing < 0) clothing = 0;
      case "instruments":
        instruments += amount;
        if (instruments < 0) instruments = 0;
      case "humans":
        if (amount < 0 && amount < -config.max_person_gain) amount = -config.max_person_gain;
        else if (amount > config.max_person_gain) amount = config.max_person_gain;
        humans += amount;
        if (humans > config.max_party) humans = config.max_party;
        else if (humans < 1) humans = 1;
    }
  }
  
  public static function capResources()
  {
    var max = maxCarry();
    if (food > max) food = max;
    if (water > max) water = max;
    if (clothing > max) clothing = max;
    if (instruments > max) instruments = max;
  }
  
  public static function step(?tile:HexTile)
  {
    if (Key.isDown(Key.F2))
    {
      food = 9999;
      water = 9999;
      instruments = 9999;
      clothing = 9998;
    }
    var consumeFood = humans;
    var consumeWater = humans;
    var consumeClothing = 0;
    var someoneDies:Bool = false;
    if (tile != null)
    {
      if (tile.resource != -1)
      {
        gather(tile.type, tile.resource);
        tile.resource = -1;
      }
      var info:TileBalance = Reflect.field(config.tiles, tile.type.getName());
      consumeFood = info.foodPerPerson * humans;
      consumeWater = info.waterPerPerson * humans;
      consumeClothing = info.clothingPerPerson * humans;
      if (tile.quest == 1)
      {
        GameMap.current.event.show(tile.type);
        tile.quest = -1;
      }
      else if (tile.quest == 10)
      {
        SoundSystem.playMusic(Res.sfx.ld_jingle_win, false);
        GameMap.current.event.showCustom(Const.VICTORY, finish, function() {});
      }
      tile.updateIcon();
    }
    
    food -= consumeFood;
    water -= consumeWater;
    clothing -= consumeClothing;
    if (food < 0)
    {
      food = 0;
      someoneDies = true;
    }
    if (water < 0)
    {
      water = 0;
      someoneDies = true;
    }
    if (clothing < 0)
    {
      clothing = 0;
    }
    
    if (someoneDies)
    {
      if (humans == 1)
      {
        hunger++;
        if (hunger > config.hungerLimit) humans--;
      }
      else humans--;
      if (humans <= 0)
      {
        humans = 0;
        // trace("YER DED");
        gameOver();
        return;
      }
    }
    else if (food > 0) hunger = 0;
    
    capResources();
    // trace('PEOPLE: $humans\n---\nFood: $food\nWater: $water\nClothing: $clothing\nInstruments: $instruments');
    viewDist = 3;
    GameMap.current.step();
    ui.step();
  }
  
  static function gameOver()
  {
    SoundSystem.playMusic(Res.sfx.ld_jingle_lose, false);
    GameMap.current.event.showCustom(Const.FAIL, restart, null );
  }
  
  static function finish()
  {
    restart();
  }
  
  static function restart()
  {
    if (GameMap.current != null)
    {
      GameMap.current.tileInfo.remove();
      GameMap.current.event.remove();
      GameMap.current.remove();
    }
		var map = new GameMap(Main.instance.s3d);
		map.load(State.config.pool.first, 0, 0, true);
		Main.syncUpdate();
		State.start();
  }
  
  public static function menu()
  {
    restart();
    // if (GameMap.current != null)
    // {
    //   GameMap.current.tileInfo.remove();
    //   GameMap.current.event.remove();
    //   GameMap.current.remove();
    //   ui.visible = false;
    // }
    // new MainMenu(Main.instance.s2d);
  }
  
}

typedef BalanceConfig = {
  var gatherPerPeson:Float;
  var hungerLimit:Int;
  var max_person_gain:Int;
  var max_party:Int;
  var camp_cost:Int;
  var tiles:Dynamic<TileBalance>;
  var events:Array<EventConfig>;
  var pool:PoolConfig;
};

typedef ResourceGather = {
  var type:String;
  var amount:Int;
};

typedef EventConfig = {
  var id:String;
  var text:String;
  var accept:Array<Array<Dynamic>>;
  var deny:Array<Array<Dynamic>>;
  var min_population:Int;
}

typedef TileBalance = {
  var foodPerPerson:Int;
  var waterPerPerson:Int;
  var clothingPerPerson:Int;
  var instruments: { use:Int, convert:String };
  var gather:Array<Array<Dynamic>>; // [string,int]
  var events:Array<String>;
  var descr:String;
};

typedef PoolConfig = {
  var first:String;
  var last:String;
  var easy:Array<String>;
  var normal:Array<String>;
  var hard:Array<String>;
  var dist_easy:Int;
  var dist_normal:Int;
  var dist_hard:Int;
  var events_easy:Array<Int>;
  var events_normal:Array<Int>;
  var events_hard:Array<Int>;
}