import h2d.Particles;
import dn.Tweenie;
import h2d.Bitmap;
import format.flac.Data;
import hscript.Parser;
import hscript.Interp;
import dn.M;
import hxd.Music;
import hxd.Res;
import haxe.Json;

class State {
  
  public static var i:State;
  
  public var config:ConfigFile;
  public var stage:Int = 0;
  public var step:Int = 0;
  public var projected:Int = 0;
  public var evo:Evolution;
  public var scavengeCount:Int = 0;
  
  public var stats = new Map<StatName, Float>();
  public var flags = new Map<StateFlags, Int>();
  public var resources = new Map<ActionName, Int>();
  
  var dialogue:Map<String, { first: String, second:String, random: Array<String>, times:Int }>;
  var interp:Interp;
  var parser:Parser;
  
  public function new(from:Evolution) {
    #if debug
    Res.config.entry.watch(refreshConfig);
    #end
    inline refreshConfig();
    
    stats = [
      Health => 0,
      Hunger => 0,
      Humanity => 0,
    ];
    resources = [
      Veggies => config.state.veggies,
      Meat => config.state.meat,
      Cloth => config.state.cloth,
      Armor => config.state.armor,
      Toy => config.state.toy,
      Medicine => config.state.meds
    ];
    evo = from;
    stage = from.stage() - 1;
    flags = [
      Sick => 0,
      Unhappy => 0,
      Hungry => 0,
      Evil => 0,
      Good => 0,
      Dying => 0,
      Unsafe => 0,
      LongHunger => 0,
      LongUnhappy => 0,
      Lonely => 0,
      Veggies => 0,
      Meat => 0,
      Cloth => 0,
      Armor => 0,
      Toy => 0,
      Medicine => 0,
    ];
    nextStage();
    projected = 0;
    
    parser = new Parser();
    interp = new Interp();
    interp.variables.set("logic", interp.execute(parser.parseString(Res.triggers.entry.getText())));
  }
  
  public function exec(script:String):Dynamic {
    for (stat in stats.keyValueIterator()) {
      interp.variables[(stat.key:String)] = stat.value;
    }
    for (flag in flags.keyValueIterator()) {
      interp.variables[flag.key] = flag.value;
    }
    return interp.expr(parser.parseString(script));
  }
  
  public function currEvo():EvoConfig {
    return Reflect.field(config.evolutions, evo);
  }
  
  public function getEvo(name:Evolution):EvoConfig {
    return Reflect.field(config.evolutions, name);
  }
  
  public function incFlag(flag:StateFlags) {
    var cur = flags[flag];
    if (cur == null) flags[flag] = 1;
    else flags[flag] = cur+1;
  }
  
  public inline function hasFlag(flag:StateFlags) {
    return flags[flag] > 0;
  }
  
  public function incStats(stat:ActionBalance, flag:StateFlags) {
    stats[Health] += stat.health;
    stats[Hunger] += stat.hunger;
    trace(flag, flags.get(Evil), stat.humanity);
    if (flag == Toy) {
      if (flags.get(Evil) > 0) stats[Humanity] -= stat.humanity;
      else if (flags.get(Good) > 0) stats[Humanity] += stat.humanity;
    }
    else stats[Humanity] += stat.humanity;
    inline incFlag(flag);
  }
  
  function nextStage() {
    stage++;
    step = 0;
    var conf = currEvo();
    for (f in flags.keys()) flags[f] = 0;
    for (f in conf.flags) {
      flags[f] = 1;
    }
    flags[Unsafe] = config.evo_min[stage];
    stats.set(Health, conf.health);
    stats.set(Hunger, conf.hunger);
    stats.set(Humanity, conf.humanity);
    if (Main.game != null && Main.game.pet != null) Main.game.pet.evolve(conf);
    if (R.unlocks.indexOf(evo) == -1) {
      R.unlocks.push(evo);
      R.saveSettings();
    }
    dialogue = [];
    for (line in Res.load("texts/" + conf.text + ".tsv").entry.getText().split("\n")) {
      var spl = line.split("\t");
      var id = StringTools.trim(spl[0]).toLowerCase().split(" ");
      var curr = dialogue[id[1]];
      if (curr == null) dialogue[id[1]] = curr = { first: null, second: null, random: [], times: 0 };
      if (id[0] == "1st") curr.first = StringTools.trim(spl[1]);
      else if (id[0] == "2nd") curr.second = StringTools.trim(spl[1]);
      else if (id[0] == "random") curr.random.push(StringTools.trim(spl[1]));
    }
    // TODO: Last stage
    if (stage == 3) {
      switch (evo) {
        case EvoHealer: Music.transit(null, Res.sound.jin_healer);
        case EvoGuard: Music.transit(null, Res.sound.jin_guardian);
        case EvoSoldier: Music.transit(null, Res.sound.jin_soldier);
        case EvoPredator: Music.transit(null, Res.sound.jin_predator);
        default:
      }
      Main.delayer.addF("gameover", () -> {
        new OverlayText().run(evo, () -> new EndingScreen() );
      }, 2);
      // new OverlayText().run(evo, Game.restart);
      return;
    } else {
      Main.delayer.addF("gameover", () -> {
        new OverlayText().run(evo);
      }, 2);
    }
    if (Main.game != null) {
      Main.game.ui.check();
      triggerText("turn");
    }
  }
  
  function doStep(last:Bool) {
    
    this.step++;
    if (step >= config.stages[stage]) {
      if (flags.get(Armor) + flags.get(Cloth) < 2) {
        gameover("evo_fail");
        return false;
      }
      var conf = currEvo();
      if (conf.leafs.length == 0) evo = EvoBase;
      else {
        if (exec("logic." + evo + "()")) evo = conf.leafs[0];
        else evo = conf.leafs[1];
      }
      var conf = currEvo();
      if (stage != 2) Music.transit(Res.load("sound/" + conf.music).toSound(), Res.sound.evo2);
      nextStage();
      return false;
    }
    
    if (stats[Health] <= 0) {
      if (evo == EvoBase) {
        gameover("death_larva");
      } else {
        gameover("death");
      }
      
      return false;
    }
    if (flags[LongUnhappy] > 3) {
      gameover("escape");
      return false;
    }
    
    stats[Health] += config.step_health;
    stats[Hunger] += config.step_hunger;
    if (stats[Hunger] <= 0) stats[Health] += config.hunger_damage;
    
    if (flags.get(Sick) > 0) {
      stats[Health] += config.sick_health;
      stats[Humanity] += config.sick_humanity;
    }
    if (flags.get(Lonely) > config.lonely_time) {
      stats[Humanity] += config.lonely_humanity;
    }
    for (k in stats.keys()) {
      if (stats[k] < 0) stats[k] = 0;
      if (stats[k] > 100) stats[k] = 100;
    }
    
    
    if (flags.get(Good) > 0) incFlag(Lonely);
    if (stats[Hunger] / 100 <= config.hungry_percent) incFlag(Hungry);
    else flags[Hungry] = 0;
    if (stats[Humanity] / 100 <= config.unhappy_percent) incFlag(Unhappy);
    else flags[Unhappy] = 0;
    if (stats[Health] / 100 <= config.dying_percent) incFlag(Dying);
    else flags[Dying] = 0;
    if (flags[Unsafe] < 0) flags[Unsafe] = 0;
    
    if (flags[Hungry] > config.long_time || flags[LongHunger] < 0) incFlag(LongHunger);
    else flags[LongHunger] = 0;
    if (flags[LongHunger] > config.sick_timer) incFlag(Sick);
    
    if (flags[Unhappy] > config.long_time) incFlag(LongUnhappy);
    else flags[LongUnhappy] = 0;
    
    if (last) {
      doEmote();
      shownText = false;
      Main.game.ui.check();
    }
    return true;
  }
  public var action:ActionName;
  public function doEmote(max:Int = 3) {
    var shown = 0;
    var conf = currEvo();
    var pet = Main.game.pet;
    pet.clearQueue();
    inline function showEmote(i:EmoteIndex) {
      if (conf.emotions.indexOf(i.toName()) != -1) {
        pet.emote(i);
        shown++;
        triggerText(i.toTrigger());
        return true;
      }
      return false;
    }
    if (hasFlag(Dying)) {
      pet.emote(Dying);
      shown++;
    }
    if (hasFlag(LongHunger)) {
      if (!showEmote(Feeble)) showEmote(UFeeble);
    }
    if (hasFlag(LongUnhappy)) {
      if (!showEmote(Restless)) showEmote(URestless);
    }
    var showAnger = false;
    if (shown < max && hasFlag(Evil) && (hasFlag(LongHunger) || hasFlag(Sick)) && Math.random() > 0.5) {
      showAnger = showEmote(Angry) || showEmote(UAngry);
    }
    if (shown < max && hasFlag(Hungry)) {
      if (!showEmote(Hungry)) showEmote(UHungry);
    }
    if (hasFlag(Unsafe) && (config.stages[stage] - step) <= 5) {
      if (!showEmote(Unsafe)) showEmote(UUnsafe);
    }
    if (flags[Lonely] > config.lonely_time) showEmote(Lonely);
    if (action != null) {
      if (!showAnger && hasFlag(Evil) && action == Toy) showEmote(Angry);
      else showEmote(Respectful);
      action = null;
    }
    if (shown < 2 && Math.random() > 0.5) if (!showEmote(Content) && !showEmote(Happy)) showEmote(UContent);
    if (!shownText && shown != 0) triggerText("any");
  }
  
  public var shownText = false;
  public function triggerText(id:String, force:Bool = false) {
    if (shownText && !force) {
      // trace("SKIP ID" + id);
      return;
    }
    var v = dialogue[id];
    if (v == null) return; // nothing to show
    var what = null;
    if (v.times == 0 && v.first != null) what = v.first;
    else if (v.times == 1 && v.second != null) what = v.second;
    else what = v.random[dn.M.rand(v.random.length)];
    // trace(id, v.times, what);
    v.times++;
    if (what == null) return;
    if (Main.game != null) Main.game.ui.text.show(what);
    shownText = true;
  }
  
  function gameover(id:String) {
    switch (id) {
      case "death_larva":
        Music.jingle(Res.sound.sfx_death_larva);
        var b = new Bitmap(R.a.sub(389, 149, 31, 20), Main.game.root);
        b.setPosition(144, 86);
      case "death":
        var b = new Bitmap(R.a.sub(421, 149, 26, 20), Main.game.root);
        b.setPosition(144+4, 86);
        Music.jingle(Res.sound.sfx_death1);
      case "escape":
        Music.jingle(Res.sound.sfx_escape);
        var b = new Bitmap(R.a.sub(400, 0, 112, 92), Main.game.root);
        b.setPosition(104, 19);
        var p = new Particles(Main.game.root);
        p.load(Json.parse(Res.glass_parts.entry.getText()));
        p.x = R.W >> 1;
        p.y = 60;
        p.onEnd = () -> p.remove();
      case "evo_fail":
        var b = new Bitmap(R.a.sub(358, 149, 30, 42), Main.game.root);
        b.setPosition(144, 60);
        Music.jingle(Res.sound.sfx_death_evo);
    }
    var a = new Bitmap(Res.escape.toTile(), Main.game.root);
    Main.tw.createMs(a.alpha, 0, TType.TLinear, 500).onEnd = () -> a.remove();
    Main.game.pet.visible = false;
    Main.delayer.addF("gameover", () -> {
      if (Main.scav != null && !Main.scav.destroyed) Main.scav.destroy();
      new OverlayText().run(id, Game.restart);
    }, 2);
  }
  
  public function canScavenge() {
    return stage != 0 && step + config.costs.scavenge < config.stages[State.i.stage]-1;
  }
  
  public function advance(steps:Int) {
    while (steps>0) {
      if (!doStep(--steps == 0)) return;
    }
  }
  
  function refreshConfig() {
    config = Json.parse(Res.config.entry.getText());
  }
}

enum abstract StatName(String) from String to String {
  var Health = "health";
  var Hunger = "hunger";
  var Humanity = "humanity";
}

enum abstract ActionName(String) from String to String {
  var Veggies = "veggies";
  var Meat = "meat";
  var Armor = "armor";
  var Cloth = "cloth";
  var Medicine = "medicine";
  var Toy = "toy";
  public inline function cost() {
    return switch (this) {
      case Veggies, Meat: State.i.config.costs.food;
      case Armor, Cloth: State.i.config.costs.evofood;
      case Medicine: State.i.config.costs.heal;
      case Toy: State.i.config.costs.play;
      default: 0;
    }
  }
  public inline function name() {
    return switch this {
      case Veggies: "Fruits";
      case Meat: "Meat";
      case Cloth: "Fabric";
      case Armor: "Armor";
      case Toy: "Toys";
      case Medicine: "Medicine";
      default: "";
    }
  }
}

enum abstract Evolution(String) from String to String {
  var EvoBase = "base";
  var EvoGood = "good";
  var EvoGood2 = "good2";
  var EvoNeutral = "neutral";
  var EvoBad = "bad";
  var EvoBad2 = "bad2";
  var EvoHealer = "healer";
  var EvoGuard = "guard";
  var EvoSoldier = "soldier";
  var EvoPredator = "predator";
  
  public inline function index() {
    return switch this {
        case EvoBase: 0;
        case EvoGood: 1;
        case EvoBad: 2;
        case EvoGood2: 3;
        case EvoNeutral: 4;
        case EvoBad2: 5;
        case EvoHealer: 6;
        case EvoGuard: 7;
        case EvoSoldier: 8;
        case EvoPredator: 9;
        default: 0;
    }
  }
  
  public inline function stage() {
    return switch this {
        case EvoBase: 0;
        case EvoGood, EvoBad: 1;
        case EvoGood2, EvoNeutral, EvoBad2: 2;
        default: 3;
    }
  }
}

enum abstract EmoteIndex(Int) from Int to Int {
  
  var UContent;
  var UUnsafe;
  var UFeeble;
  var URestless;
  var UHungry;
  var UAngry;
  var Happy;
  var Content;
  var Lonely;
  var Respectful;
  var Angry;
  var Unsafe;
  var Feeble;
  var Restless;
  var Hungry;
  var Dying;
  
  public inline function toTrigger():String {
    switch (this) {
      case UContent, Content:   return "content";
      case UUnsafe, Unsafe:    return "unsafe";
      case UFeeble, Feeble:    return "feeble";
      case URestless, Restless:  return "restless";
      case UHungry, Hungry:    return "hungry";
      case UAngry, Angry:     return "angry";
      case Happy:      return "happy";
      case Lonely:     return "lonely";
      case Respectful: return "respectful";
      case Dying:      return "dying";
      default: throw "Invalid index";
    }
  }
  
  public inline function toName():EmoteName {
    switch (this) {
      case UContent:   return EmoteName.UContent;
      case UUnsafe:    return EmoteName.UUnsafe;
      case UFeeble:    return EmoteName.UFeeble;
      case URestless:  return EmoteName.URestless;
      case UHungry:    return EmoteName.UHungry;
      case UAngry:     return EmoteName.UAngry;
      case Happy:      return EmoteName.Happy;
      case Content:    return EmoteName.Content;
      case Lonely:     return EmoteName.Lonely;
      case Respectful: return EmoteName.Respectful;
      case Angry:      return EmoteName.Angry;
      case Unsafe:     return EmoteName.Unsafe;
      case Feeble:     return EmoteName.Feeble;
      case Restless:   return EmoteName.Restless;
      case Hungry:     return EmoteName.Hungry;
      case Dying:      return EmoteName.Dying;
      default: throw "Invalid index";
    }
  }
}
enum abstract EmoteName(String) from String to String {
  
  var UContent;
  var UUnsafe;
  var UFeeble;
  var URestless;
  var UHungry;
  var UAngry;
  var Happy;
  var Content;
  var Lonely;
  var Respectful;
  var Angry;
  var Unsafe;
  var Feeble;
  var Restless;
  var Hungry;
  var Dying;
  
  public inline function toIndex():EmoteIndex {
    switch (this) {
      case UContent:   return EmoteIndex.UContent;
      case UUnsafe:    return EmoteIndex.UUnsafe;
      case UFeeble:    return EmoteIndex.UFeeble;
      case URestless:  return EmoteIndex.URestless;
      case UHungry:    return EmoteIndex.UHungry;
      case UAngry:     return EmoteIndex.UAngry;
      case Happy:      return EmoteIndex.Happy;
      case Content:    return EmoteIndex.Content;
      case Lonely:     return EmoteIndex.Lonely;
      case Respectful: return EmoteIndex.Respectful;
      case Angry:      return EmoteIndex.Angry;
      case Unsafe:     return EmoteIndex.Unsafe;
      case Feeble:     return EmoteIndex.Feeble;
      case Restless:   return EmoteIndex.Restless;
      case Hungry:     return EmoteIndex.Hungry;
      case Dying:      return EmoteIndex.Dying;
      default: throw "Invalid index";
    }
  }
  
}

enum abstract StateFlags(String) from String to String {
  
  var Sick = "sick";
  var Unhappy = "unhappy";
  var Hungry = "hungry";
  var Evil = "evil";
  var Good = "good";
  var Dying = "dying";
  var Unsafe = "unsafe";
  var LongHunger = "long_hunger";
  var LongUnhappy = "long_unhappy";
  var Lonely = "lonley";
  
  var Veggies = "veggies";
  var Meat = "meat";
  var Cloth = "cloth";
  var Armor = "armor";
  var Toy = "toy";
  var Medicine = "medicine";
  
}

typedef ConfigFile = {
  var state: {
    veggies: Int,
    meat: Int,
    cloth: Int,
    armor: Int,
    meds: Int,
    toy: Int
  };
  var evolutions: {
    base: EvoConfig,
    good: EvoConfig,
    good2: EvoConfig,
    neutral: EvoConfig,
    bad: EvoConfig,
    bad2: EvoConfig,
    healer: EvoConfig,
    guard: EvoConfig,
    soldier: EvoConfig,
    predator: EvoConfig
  };
  var stages:Array<Int>;
  var costs: { scavenge:Int, food:Int, evofood:Int, heal:Int, play:Int };
  var balance: {
    veggies: ActionBalance,
    meat: ActionBalance,
    armor: ActionBalance,
    cloth: ActionBalance,
    medicine: ActionBalance,
    toy: ActionBalance
  };
  var step_hunger: Float;
  var step_health: Float;
  var sick_humanity: Float;
  var sick_health: Float;
  var lonely_humanity: Float;
  var sick_timer:Int;
  var meds_timer:Int;
  var hunger_damage:Float;
  
  var long_time: Int;
  var hungry_percent: Float;
  var unhappy_percent: Float;
  var dying_percent: Float;
  var lonely_time: Int;
  var evo_min:Array<Int>;
  
  var scavenge_amount:Int;
  var scavenge_turns:Int;
}

typedef ActionBalance = {
  var health:Float;
  var hunger:Float;
  var humanity:Float;
}

typedef EvoConfig = {
  var health:Int;
  var hunger:Int;
  var humanity:Int;
  var emotions:Array<EmoteName>;
  var flags:Array<String>;
  var index:Int;
  var music:String;
  var leafs:Array<Evolution>;
  
  var text:String;
  var name:String;
  var info:Array<String>;
}