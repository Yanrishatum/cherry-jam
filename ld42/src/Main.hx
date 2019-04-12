package;

import game.comps.GameUI;
import engine.Music;
import engine.Locale;
import hxd.snd.ChannelGroup;
import engine.utils.DebugDIsplay;
import engine.utils.MacroUtil;
import hxd.Timer;
import haxe.Json;
import engine.HXP;
import engine.S3DComponent;
import h3d.scene.Object;
import h3d.mat.Texture;
import hxd.fmt.hmd.Library;
import hxd.Res;
import h3d.prim.Cube;
import h3d.scene.Mesh;
import gasm.core.Entity;
import gasm.heaps.HeapsContext;
import engine.S3DRenderer;
import engine.HPEngine;
import game.TestScene;
import game.BattleScene;
import game.data.ConfigJson;
import game.data.MagicRef;

class Main extends HPEngine {
  
  public static var config:ConfigJson;
  public static var magic:Map<String, MagicRef>;
  
  public static var sfxChannel(get, never):ChannelGroup;
  private static function get_sfxChannel():ChannelGroup { return HXP.sfxChannel; }
  
  public static var state:Int = 0;
  
  public static var flags:Array<String> = new Array();
  public static var atbSpeed:Float = 1;
  
  public static function main()
  {
    // h3d.mat.MaterialSetup.current = new h3d.mat.PbrMaterialSetup();
    #if (js || embed_res)
    hxd.Res.initEmbed();
    #else
    hxd.Res.initLocal();
    // // var dir:String = MacroUtil.resPath();
    // // if( dir == null || !sys.FileSystem.exists(dir)) dir = "res";
    // // if (!sys.FileSystem.exists(dir))
    // // {
    // //   if (sys.FileSystem.exists("./config.json")) dir = "./";
    // //   else if (sys.FileSystem.exists("../config.json")) dir = "../";
    // //   else throw "Can't find assets!";
    // // }
    // // hxd.Res.loader = new hxd.res.Loader(new hxd.fs.LocalFileSystem(dir));
    #end
    Main.config = Json.parse(Res.config.entry.getText());
    magic = new Map();
    
    Music.precache("dialogue_thing.mp3");
    Music.precache("fight_thing.mp3");
    Music.precache("loser_thing.mp3");
    Music.precache("win_thing.mp3");
    Music.precache("menu_thing.mp3");
    for (m in config.spells)
    {
      var spell:MagicRef = new MagicRef(m);
      magic.set(spell.name, spell);
    }
    // game.comps.GameUI.bleep();
    // game.comps.GameUI.bleep(true);
    // game.comps.GameUI.click();
    Locale.init("en");
    
    // trace(config);
    new Main();
  }
  
  public function new()
  {
    super();
    
  }
  
  override function init() {
    super.init();
    
    // #if !jsrelease
    HXP.musicChannel.volume = 0.5;
    HXP.sfxChannel.volume = 0.5;
    // #end
    
    DebugDisplay.init();
    
    #if hl
    // engine.resize(1280, 720);
    #end
    GameUI.init_base();
    // scene = new BattleScene();
    scene = new game.MenuScene();
    
    #if js
    js.Syntax.code("window.addEventListener(\"wheel\", (e) => { e.preventDefault(); return false; })");
    #end
    /*
    var obj:Object = HXP.modelCache.loadLibrary(Res.test).makeObject((id:String) -> null);
    obj.x = 20;
    var ent:Entity = new Entity();
    ent.add(new S3DComponent(obj));
    
    baseEntity.addChild(ent);
    
    // activate lights on boss cubes
    for (mat in obj.getMaterials())
    {
      mat.mainPass.enableLights = true;
      mat.shadows = true;
    }*/
    /*
    var lib:Library = Res.test.toHmd();
    var obj:Object = lib.makeObject(loadModelTexture);
    
    var ent:Entity = new Entity();
    ent.add(new S3DComponent(obj));
    context.baseEntity.addChild(ent);
    
		// adds a directional light to the scene
		var light = new h3d.scene.DirLight(new h3d.Vector(0.5, 0.5, -0.5), s3d);
		light.enableSpecular = true;

		// set the ambient light to 30%
		s3d.lightSystem.ambientLight.set(0.3, 0.3, 0.3);

		// activate lights on boss cubes
		obj.getMaterials()[0].mainPass.enableLights = true;*/
  }
  
}
