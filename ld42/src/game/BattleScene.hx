package game;

import hxd.Key;
// import h3d.scene.pbr.DirLight;
import h3d.scene.fwd.DirLight;
import engine.Music;
import hxd.Res;
import h3d.Vector;
import engine.utils.DebugDIsplay;
import h2d.Flow;
import engine.HXP;
import h2d.Text;
import gasm.heaps.text.ScalingTextField;
import gasm.heaps.components.HeapsTextComponent;
import gasm.core.Entity;
import h3d.scene.CameraController;
import engine.HScene;
import game.GridMap;
import game.comps.Character;
import game.comps.GameUI;
import game.comps.Skybox;
import game.comps.MagicCast;
import game.comps.SpellAnnouncer;
import game.comps.VNDisplay;

class BattleScene extends HScene
{
  
  public static var instance:BattleScene;
  public static var text:Text;
  
  private var map:GridMap;
  private var camera:CameraController;
  private var light:DirLight;
  
  public var boss:Character;
  public var gale:Character;
  public var inori:Character;
  public var ricard:Character;
  public var chars:Array<Character>;
  
  public var ui:GameUI;
  public var announcer:SpellAnnouncer;
  public var spellcast:MagicCast;
  
  public var vn:VNDisplay;
  
  public var updateAtb:Bool = true;
  
  
  public function new()
  {
    instance = this;
    super("battle");
  }
  
  override public function setup()
  {
    
    // light.enableSpecular = true;
    

    // set the ambient light to 30%
    text = new Text(hxd.res.DefaultFont.get(), HXP.engine.s2d);
    
    var isPbr = Std.is(s3d.renderer, h3d.scene.pbr.Renderer);
		var shadow:h3d.pass.DefaultShadowMap = null;
    if (!isPbr)
    {
      shadow = s3d.renderer.getPass(h3d.pass.DefaultShadowMap);
      shadow.power = 45.5;
      shadow.blur.radius = 5.8;
      shadow.blur.quality = 0.285;
      shadow.bias = 0.002;
      shadow.color.set(.54, .54, .63);
    }
    s3d.lightSystem.ambientLight.set(0.46, 0.46, 0.58);
    
    var dirV:Vector = new Vector(-.35, 0.5, -0.5);
    // var dirV:Vector = new Vector(0.22, 0.5, -0.5);
    var light = this.light = new DirLight(dirV);
    light.color.set(.9, .885, .96, 1);
    /*
    var dirV:Vector = new Vector(0.5, 0.5, -0.5);
    shadow.power = 23;
    shadow.blur.radius = 20;
    shadow.blur.quality = 0.37;
    shadow.bias = 0;
    s3d.lightSystem.ambientLight.set(0, 0, 0.2);
    
    light.color.set(2, 1.47, 1.11, 1);
    */
    
    
    super.setup();
    
    add(new Skybox().owner);
    
    map = new GridMap(8, 8);
    var index:Array<HexType> = [for(n in Main.config.map_index) HexType.createByName(n)];
    var tiles:Array<HexType> = new Array();
    for (line in Main.config.map)
    {
      var split:Array<String> = line.split(" ");
      for (i in split)
      {
        tiles.push(index[Std.parseInt(i)]);
      }
    }
    map.fill(tiles);
    for (h in map.map)
    {
      owner.addChild(h.owner);
    }
    gale = new Character(this, "Gale", Main.config.stats.gale);
    inori = new Character(this, "Inori", Main.config.stats.inori);
    ricard = new Character(this, "Ricard", Main.config.stats.ricard);
    boss = new Character(this, "Violette", Main.config.stats.boss);
    chars = [gale, inori, ricard];
    ui = new GameUI(this);
    ui.addChar(gale);
    ui.addChar(inori);
    ui.addChar(ricard);
    ui.addChar(boss);
    
    announcer = new SpellAnnouncer();
    vn = new VNDisplay(this);
    
    add(gale.owner);
    add(inori.owner);
    add(ricard.owner);
    add(boss.owner);
    add(ui.owner);
    add(announcer.owner);
    add(vn.owner);
    
    // owner.addChild(new Character("Inori", 9999, 2).owner);
    // owner.addChild(new Character("Ricard", 9999, 2).owner);
    
    DebugDisplay.beginGroup("Lighting", false);
    
    if (!isPbr)
    {
      DebugDisplay.addSliderF("Power", function() return shadow.power, function(p) shadow.power = p, 0, 100);
      DebugDisplay.addSliderF("Radius", function() return shadow.blur.radius, function(r) shadow.blur.radius = r, 0, 20);
      DebugDisplay.addSliderF("Quality", function() return shadow.blur.quality, function(r) shadow.blur.quality = r);
      DebugDisplay.addSliderF("Bias", function() return shadow.bias, function(r) shadow.bias = r, 0, 0.1);
    }
    
    DebugDisplay.addSliderF("Light R", function() return light.color.r, function(p) light.color.r = p, 0, 3);
    DebugDisplay.addSliderF("Light G", function() return light.color.g, function(p) light.color.g = p, 0, 3);
    DebugDisplay.addSliderF("Light B", function() return light.color.b, function(p) light.color.b = p, 0, 3);
    
    DebugDisplay.addSliderF("Ambient R", function() return s3d.lightSystem.ambientLight.r, function(p) s3d.lightSystem.ambientLight.r = p, 0, 2);
    DebugDisplay.addSliderF("Ambient G", function() return s3d.lightSystem.ambientLight.g, function(p) s3d.lightSystem.ambientLight.g = p, 0, 2);
    DebugDisplay.addSliderF("Ambient B", function() return s3d.lightSystem.ambientLight.b, function(p) s3d.lightSystem.ambientLight.b = p, 0, 2);
    
    if (!isPbr)
    {
      DebugDisplay.addSliderF("Shadow R", function() return shadow.color.r, function(p) shadow.color.r = p, 0, 3);
      DebugDisplay.addSliderF("Shadow G", function() return shadow.color.g, function(p) shadow.color.g = p, 0, 3);
      DebugDisplay.addSliderF("Shadow B", function() return shadow.color.b, function(p) shadow.color.b = p, 0, 3);
    }
    
    DebugDisplay.addSliderF("Light X", function() return dirV.x, function(p) { dirV.x = p; light.setDirection(dirV); }, -1, 1);
    DebugDisplay.addSliderF("Light Y", function() return dirV.y, function(p) { dirV.y = p; light.setDirection(dirV); }, -1, 1);
    DebugDisplay.addSliderF("Light Z", function() return dirV.z, function(p) { dirV.z = p; light.setDirection(dirV); }, -1, 1);
    
    
    DebugDisplay.endGroup();
    
    DebugDisplay.beginGroup("Chars", false);
    DebugDisplay.addButton("Anim: Idle", () -> { for(c in chars) c.playAnim('idle'); boss.playAnim('idle'); });
    DebugDisplay.addButton("Anim: Cast", () -> { for(c in chars) c.playAnim('cast'); boss.playAnim('cast'); });
    DebugDisplay.addButton("Anim: Dead", () -> { for(c in chars) c.playAnim('dead'); boss.playAnim('dead'); });
    DebugDisplay.addButton("Anim: Hurt", () -> { for(c in chars) c.playAnim('hurt'); boss.playAnim('hurt'); });
    DebugDisplay.addSliderF("Gale HP", () -> gale.hp, (v) -> gale.hp = v, 0, 9999);
    DebugDisplay.addSliderF("Inori HP", () -> inori.hp, (v) -> inori.hp = v, 0, 9999);
    DebugDisplay.addSliderF("Ricard HP", () -> ricard.hp, (v) -> ricard.hp = v, 0, 9999);
    DebugDisplay.addSliderF("Violetta HP", () -> boss.hp, (v) -> boss.hp = v, 0, 999999);
    DebugDisplay.endGroup();
    
    DebugDisplay.beginGroup("Volume", true);
    DebugDisplay.addSliderF("SFX", () -> Main.sfxChannel.volume, (v) -> Main.sfxChannel.volume = v);
    DebugDisplay.addSliderF("Music", () -> HXP.musicChannel.volume, (v) -> HXP.musicChannel.volume = v);
    DebugDisplay.endGroup();
    DebugDisplay.flow.visible = false;
    // new h3d.scene.CameraController(s3d).loadFromCamera();
  }
  
  override public function begin()
  {
    s3d.camera.pos.set(359, 401, 263);
    s3d.camera.target.set(88, 64, 15);
    Main.flags = new Array();
    updateAtb = false;
    vn.show(Res.loc.intro);
    #if js
    Music.play("dialogue_thing.mp3");
    #else
    Music.play(Res.sfx.music.dialogue_thing);
    #end
    
    // var magic:MagicCast = new MagicCast(Main.magic.get("tempest_howl"));
    // add(magic.owner);
    // magic.startSel();
// x:359.9649044602498
// y:401.60230068469207
// z:263.4070646641635
// w:1
// up:h3d.Vector
// target:h3d.Vector
// x:88.25734096972826
// y:64.98121888445523
// z:15.725871599647839
// w:1
    if (camera == null)
    {
      camera = new h3d.scene.CameraController(s3d);
      camera.loadFromCamera();
    }
    else 
    {
      s3d.addChild(camera);
    }
    s3d.addChild(light);
  }
  
  override public function end()
  {
    s3d.removeChild(camera);
    s3d.removeChild(light);
  }
  
  override public function update(delta:Float)
  {
    super.update(delta);
    if (Key.isReleased(Key.W) && Key.isDown(Key.SHIFT))
    {
      DebugDisplay.flow.visible = !DebugDisplay.flow.visible;
    }
  }
  
}