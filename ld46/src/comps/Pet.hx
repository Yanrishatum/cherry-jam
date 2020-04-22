package comps;

import h2d.Interactive;
import hxd.snd.Channel;
import hxd.res.Sound;
import haxe.Json;
import h2d.Particles;
import h2d.Animation;
import h2d.AnimationExt;
import State;
import hxd.Res;
import h2d.Bitmap;
import h2d.Object;

class Pet extends Object {
  
  public var type:EvoConfig;
  var anim:AnimationExt;
  var parts:Particles;
  
  public function new(type:EvoConfig, ?parent) {
    super(parent);
    setPosition(144, 50);
    anim = new AnimationExt(this);
    parts = new Particles(this);
    parts.load(Json.parse(Res.eat_veggies.entry.getText()), Res.eat_veggies.entry.path);
    for (g in parts.getGroups()) {
      g.rebuildOnChange = false;
      g.isRelative = false;
      g.enable = false;
    }
    parts.onEnd = disableParts2;
    var inter = new Interactive(34, 52, this);
    inter.onClick = interact;
    evolve(type);
  }
  
  public function evolve(type:EvoConfig) {
    this.type = type;
    anim.animations.set("idle", new AnimationDescriptor(frames(type.index)));
    anim.play(anim.animations["idle"].frames);
  }
  
  public static function frames(index:Int) {
    return if (index > 5) [for(i in 0...4) new AnimationFrame(R.b.sub(35*i, 294 + 53 * (index-6), 34, 52), .180)];
    else [for(i in 0...4) new AnimationFrame(R.b.sub(33*i, 49 * index, 32, 48), .180)];
  }
  
  static final EMOTE_SFX:Map<EmoteIndex, String> = [
    UContent => "content",
    UUnsafe => "unsafe",
    UFeeble => "feeble2",
    URestless => "restless",
    UHungry => "hungry",
    UAngry => "angry",
    Happy => "happy",
    Content => "content",
    Lonely => "lonely",
    Respectful => "respectful",
    Angry => "angry",
    Unsafe => "unsafe",
    Feeble => "feeble2",
    Restless => "restless",
    Hungry => "hungry",
    Dying => "dying",
  ];
  
  function interact(_) {
    State.i.flags.set(Lonely, 0);
    if (State.i.flags.get(Evil) > 0) if (Math.random() > .5) emote(type.emotions.indexOf(Angry) == -1 ? UAngry : Angry);
    else if (!(State.i.flags.get(Good) > 0) && Math.random() > .5) emote(type.emotions.indexOf(Content) == -1 ? UContent : Content);
    
    State.i.triggerText("interact", true);
    anim.y = anim.height * .1;
    anim.scaleY = 0.9;
    Main.delayer.addMs("interact0", () -> {
      anim.y = anim.height * -.05;
      anim.scaleY = 1.05;
    }, 500);
    Main.delayer.addMs("interact1", () -> {
      anim.y = 0;
      anim.scaleY = 1;
    }, 600);
  }
  
  var flipEmote:Bool;
  var lastSound:Channel;
  var emoteChain:Array<EmoteIndex> = [];
  public inline function clearQueue() {
    emoteChain = [];
  }
  
  public function emote(index:EmoteIndex) {
    if (lastSound != null && lastSound.position < lastSound.duration) {
      emoteChain.push(index);
      return;
    }
    var f = flipEmote;
    flipEmote = !flipEmote;
    var e = new Emote(index, f, this);
    e.x = (f ? 0 : anim.width) + dn.M.frandRange(-5, 5);
    e.y = dn.M.rand(30)-10;
    var chn = R.s(Res.load("sound/em/sfx_" + EMOTE_SFX[index] + ".mp3").toSound());
    chn.onEnd = () -> {
      lastSound = null;
      if (emoteChain.length != 0) emote(emoteChain.shift());
    };
    lastSound = chn;
  }
  
  public function action(act:ActionName):Bool {
    // emote(dn.M.rand(16));
    var s = getScene();
    parts.x = -x + s.mouseX;
    parts.y = -y + s.mouseY;
    parts.syncPos();
    var oldStat = State.i.flags.get(Veggies);
    switch (act) {
      case Veggies:
        enableGroup("veggies");
        R.s(Res.sound.sfx_veggies);
        State.i.incStats(State.i.config.balance.veggies, Veggies);
      case Medicine:
        enableGroup("meds");
        R.s(Res.sound.sfx_medicine);
        State.i.incStats(State.i.config.balance.medicine, Medicine);
        var curr = State.i.flags[Sick];
        if (curr > 0) {
          State.i.flags[Sick] = 0;
          if (State.i.flags[LongHunger] > 0)
            State.i.flags[LongHunger] = 0;
        } else {
          State.i.flags[LongHunger] = State.i.config.sick_timer - State.i.config.meds_timer;
        }
      case Meat:
        enableGroup("meat");
        R.s(Res.sound.sfx_meat);
        State.i.incStats(State.i.config.balance.meat, Meat);
      case Toy:
        enableGroup("toy");
        if (State.i.flags.get(Evil) > 0) R.s(Res.sound.sfx_toy_tear);
        else if (State.i.flags.get(Good) > 0) R.s(Res.sound.sfx_toy_play);
        else R.s(Res.sound.sfx_toy_unsure);
        State.i.incStats(State.i.config.balance.toy, Toy);
      case Armor:
        enableGroup("meat");
        R.s(Res.sound.sfx_armor);
        State.i.incStats(State.i.config.balance.armor, Armor);
        State.i.flags[StateFlags.Unsafe]--;
      case Cloth:
        enableGroup("veggies");
        R.s(Res.sound.sfx_cloth);
        State.i.incStats(State.i.config.balance.cloth, Cloth);
        State.i.flags[StateFlags.Unsafe]--;
    }
    State.i.shownText = false;
    State.i.triggerText(act);
    
    State.i.resources[act]--;
    State.i.advance(act.cost());
    Main.delayer.addS("eat", disableParts, 1);
    return true;
  }
  
  function enableGroup(name:String) {
    var g =parts.getGroup(name);
    g.enable = true;
    g.emitLoop = true;
    g.rebuild();
  }
  
  function disableParts() {
    for (g in parts.getGroups()) {
      g.emitLoop = false;
    }
  }
  
  function disableParts2() {
    for (g in parts.getGroups()) g.enable = false;
  }
  
}