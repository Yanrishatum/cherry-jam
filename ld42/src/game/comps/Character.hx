package game.comps;

import engine.Music;
import h3d.Vector;
import hxd.res.Model;
import engine.shaders.PlayStationShader;
import h3d.anim.Animation;
import game.data.MagicRef;
import game.data.ConfigJson;
import hxd.Timer;
import hxd.Res;
import h3d.shader.BaseMesh;
import engine.HXP;
import h3d.scene.Mesh;
import h3d.scene.Object;
import engine.S3DComponent;
import engine.HComp;
import engine.utils.ModelUtil;

class Character extends HComp
{
  public var cname:String;
  public var hp:Float;
  public var hpMax:Float;
  
  public var atb:Float;
  public var atbSpeed:Float;
  
  public var attack:Float;
  public var spells:Array<MagicRef>;
  
  private var source:Model;
  private var mesh:S3DComponent;
  private var model:Object;
  
  private var ref:CharJson;
  private var battle:BattleScene;
  
  public var defending:Bool;
  private var anim:String;
  
  private var spellCast:Object;
  
  public var casting:MagicRef;
  public var godhand:Object;
  private var godhandOffset:Float;
  
  public function new(battle:BattleScene, name:String, ref:CharJson)
  {
    super();
    this.battle = battle;
    this.ref = ref;
    this.cname = name;
    this.hp = this.hpMax = ref.hp;
    this.atbSpeed = 1 / ref.atb;
    // trace(name, atbSpeed);
    this.attack = ref.atk;
    this.spells = new Array();
    for (m in ref.spells)
    {
      var magic:MagicRef = Main.magic.get(m);
      if (m == null) throw "Could not find magic: " + m;
      spells.push(magic);
      if (ref.ai) magic.currCD = magic.initialCD;
    }
    this.atb = 0;
    HXP.wrap(this, name);
  }
  
  override public function setup()
  {
    // var m:Object = new Object();
    var splicer:Array<AnimSplice>;
    var platform:Model = Res.tile_hero_good;
    source = switch(cname.toLowerCase())
    {
      case "gale":
        splicer = [{ name: "idle", start: 0, end: 18 }, { name: "cast", start: 20, end: 50 }, { name: "dead", start: 50, end: 67 }, { name: "hurt", start: 50, end: 55 }];
        Res.char;
      case "inori":
        splicer = [{ name: "idle", start: 0, end: 18 }, { name: "cast", start: 21, end: 50 }, { name: "dead", start: 50, end: 67 }, { name: "hurt", start: 50, end: 55 }];
        Res.char_healer;
      case "ricard":
        splicer = [{ name: "idle", start: 0, end: 28 }, { name: "cast", start: 31, end: 64 }, { name: "dead", start: 67, end: 83 }, { name: "hurt", start: 67, end: 72 }];
        Res.char_flexer;
      case "violette":
        splicer = [{ name: "idle", start: 0, end: 28 }, { name: "cast", start: 31, end: 99 }, { name: "dead", start: 102, end: 125 }, { name: "hurt", start: 102, end: 107 }];
        platform = Res.tile_hero_bad;
        Res.char_mistress;
      default:
        splicer = [{ name: "idle", start: 0, end: 18 }, { name: "cast", start: 20, end: 50 }, { name: "dead", start: 50, end: 67 }, { name: "hurt", start: 50, end: 55 }];
        Res.char;
    }
    
    var base:Object = HXP.modelCache.loadModel(platform);
    
    model = HXP.modelCache.loadModel(source);
    // spellCast = HXP.modelCache.loadModel(Res.spell_fire);
    // base.addChild(spellCast);
    // spellCast.visible = false;
    
    owner.add(mesh = new S3DComponent(base));
    
    ModelUtil.spliceAnimations(source, splicer);
    // var anim:Animation = HXP.modelCache.loadAnimation(Res.char, "dead");
    // model.playAnimation(anim);
    
    playAnim("casti");
    
    var sign:Float = ref.x < 0 ? 1 : -1;
    mesh.obj.rotate(0, 0, Math.PI * .5);
    
    mesh.obj.setPosition((ref.x + .5 * sign) * MapHex.TILE_WIDTH, (ref.y) * MapHex.TILE_HEIGHT, 0);
    model.rotate(Math.PI *.5, 0, sign < 0 ? Math.PI : 0);//, 0, Math.PI * sign);
    model.scale(0.5);
    // model.rotate(0, 0, Math.PI);
    if (sign < 0) sign *= 2;
    var bounds = base.getBounds();
    model.setPosition(0, 0, bounds.zSize);
    base.addChild(model);
    
    godhand = HXP.modelCache.loadModel(Res.godhand);
    godhand.y = godhandOffset = model.getBounds().zSize + model.getBounds().zSize + 5;
    godhand.rotate(Math.PI*.5, Math.PI*.5, 0);
    // godhand.rotate(Math.PI*.5, Math.PI*.5, 0);
    godhand.scale(2);
    model.addChild(godhand);
    godhand.visible = false;
    
    for (m in model.getMaterials())
    {
      // if (cname == "Ricard") m.mainPass.culling = None;
      m.mainPass.addShader(new PlayStationShader(256));
      m.castShadows = false;
    }
    // for (m in spellCast.getMaterials())
    // {
    //   m.castShadows = false;
    // }
  }
  
  public function damage(amount:Float, ?kind:HexType):Void
  {
    if (hp == 0) return;
    var d:Float = amount;
    amount = hpMax * (amount / 100);
    if (amount < 0)
    {
      // heal
      hp -= amount;
      if (hp > hpMax) hp = hpMax;
    }
    else
    {
      if (defending) amount /= 2;
      hp -= amount;
      trace('$cname : $d% ${hp + amount} - $amount = $hp');
      if (hp <= 0)
      {
        hp = 0;
        // TODO: DED
        playAnim("dead");
      }
      else 
      {
        playAnim("hurt");
      }
      // TODO: Damage
    }
    var i:Int = battle.chars.indexOf(this);
    new HPAnnouncer(Math.ceil(amount), i != -1 ? (40 + i * 100) : 1280 - 200);
    if (kind != null)
    {
      switch (kind)
      {
        case HexType.Forest:
          effect(Res.spell_life, 0.5);
          Res.sfx.sfx_magic_heal.play(0.2, Main.sfxChannel);
        case HexType.Water:
          effect(Res.spell_water, 0.5);
          Res.sfx.sfx_magic_water.play(0.2, Main.sfxChannel);
        case HexType.Plains:
          effect(Res.spell_wind, 0.5);
          Res.sfx.sfx_magic_wind.play(0.2, Main.sfxChannel);
        case HexType.Mountains:
          effect(Res.spell_earth, 0.5);
          Res.sfx.sfx_magic_earthquake.play(0.2, Main.sfxChannel);
        case HexType.Wastelands:
          effect(Res.spell_fire, 0.5);
          Res.sfx.sfx_magic_meteor.play(0.2, Main.sfxChannel);
      }
    }
    if (ref.ai)
    {
      var count:Float = hp / hpMax;
      if (hp == 0)
      {
        if (Main.flags.indexOf("victory") == -1)
        {
          Main.flags.push("victory");
          battle.vn.show(Res.loc.victory);
          #if js
          Music.play("win_thing.mp3");
          #else
          Music.play(Res.sfx.music.win_thing);
          #end
        }
      }
      else if (count < .25)
      {
        if (Main.flags.indexOf("<25") == -1)
        {
          battle.vn.show(Res.loc.boss25);
          Main.flags.push("<25");
        }
      }
      else if (count < .5)
      {
        if (Main.flags.indexOf("<50") == -1)
        {
          battle.vn.show(Res.loc.boss50);
          Main.flags.push("<50");
        }
      }
    }
    else if (hp == 0)
    {
      inline function defeat()
      {
        battle.vn.show(Res.loc.defeat);
        #if js
        Music.play("loser_thing.mp3");
        #else
        Music.play(Res.sfx.music.loser_thing);
        #end
        Main.flags.push("defeat");
      }
      
      switch(cname)
      {
        case "Gale":
          if (battle.ricard.hp > 0)
          {
            if (battle.inori.hp > 0)
              battle.vn.show(Res.loc.death_gale_inori, Res.loc.death_gale_ricard);
            else
              battle.vn.show(Res.loc.death_gale_ricard);
          }
          else if (battle.inori.hp > 0)
          {
            battle.vn.show(Res.loc.death_gale_inori);
          }
          else 
          {
            defeat();
          }
        case "Inori":
          if (battle.ricard.hp > 0)
          {
            if (battle.gale.hp > 0)
              battle.vn.show(Res.loc.death_inori_ricard, Res.loc.death_inori_gale);
            else
              battle.vn.show(Res.loc.death_inori_ricard);
          }
          else if (battle.gale.hp > 0)
          {
            battle.vn.show(Res.loc.death_inori_gale);
          }
          else 
          {
            defeat();
          }
        case "Ricard":
          if (battle.inori.hp > 0)
          {
            if (battle.gale.hp > 0)
              battle.vn.show(Res.loc.death_ricard_inori, Res.loc.death_ricard_gale);
            else
              battle.vn.show(Res.loc.death_ricard_inori);
          }
          else if (battle.gale.hp > 0)
          {
            battle.vn.show(Res.loc.death_ricard_gale);
          }
          else 
          {
            defeat();
          }
      }
    }
  }
  
  private function effect(m:Model, scale:Float = 1):Void
  {
    new Effect(m, new Vector(mesh.obj.x, mesh.obj.y, mesh.obj.z + model.z), scale);
  }
  
  public function playAnim(name:String):Void
  {
    var realName:String = name;
    if (name == "attack") name = "cast";
    else if (name == "casti") name = "cast";
    this.anim = name;
    var anim:Animation = HXP.modelCache.loadAnimation(source, name);
    model.playAnimation(anim);
    if (name == "cast")
    {
      model.currentAnimation.onAnimEnd = castEnd;
      if (realName == "cast")
      {
        effect(Res.spell_cast);
        Res.sfx.sfx_magic_cast.play(0.1, Main.sfxChannel);
      }
      // spellCast.visible = true;
      // spellCast.playAnimation(HXP.modelCache.loadAnimation(Res.spell_fire));
      // spellCast.currentAnimation.onAnimEnd = hideSpellcast;
    }
    if (name == "hurt")
    {
      // model.currentAnimation.speed = .5;
      model.currentAnimation.onAnimEnd = castEnd;
    }
    else if (name == "dead")
    {
      model.currentAnimation.addEvent(model.currentAnimation.frameCount - 2, "ded");
      model.currentAnimation.onEvent = deadEnd;
    }
  }
  
  private function hideSpellcast():Void
  {
    spellCast.visible = false;
  }
  
  private function castEnd():Void
  {
    if (ref.ai && this.anim == "cast" && !battle.vn.shown)
    {
      battle.updateAtb = true;
      atb = 0;
    }
    if (casting != null)
    {
      casting.apply(battle);
      casting = null;
      battle.ui.resetAtb(false);
      
      // battle.updateAtb = true;
    }
    playAnim("idle");
  }
  
  private function deadEnd(s:String):Void
  {
    model.currentAnimation.pause = true;
  }
  
  override public function update(delta:Float)
  {
    // super.update(delta);
    // mesh.obj.rotate(0, 0, Timer.deltaT * .5);
    godhand.y = (godhandOffset - 7) + Math.abs(Math.sin(Timer.lastTimeStamp * 10) * 13);
    
    if (battle.updateAtb && hp > 0)
    {
      var mul:Float = atbSpeed * Main.atbSpeed;
      if (defending) mul += .5;
      
      atb += delta * mul;
      if (atb > 1)
      {
        defending = false;
        atb = 1;
        battle.updateAtb = false;
        godhand.visible = true;
        for (s in spells)
        {
          if (s.currCD > 0) s.currCD--;
        }
        if (ref.ai)
        {
          var available = spells.filter((m) -> (m.currCD == 0));
          var spell:MagicRef = available[HXP.randomIZ(available.length)];
          spell.currCD = spell.cooldown;
          casting = spell;
          // spell.apply(battle);
          battle.announcer.show(spell.name);
          
          playAnim("cast");
        }
      }
      else 
      {
        godhand.visible = false;
      }
    }
    godhand.visible = !(atb < 1);
  }
  
}