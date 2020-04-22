package ;

import dn.Tweenie;
import hxd.res.ManifestLoader;
import hxd.fs.ManifestBuilder;
import dn.Delayer;
import hxd.Timer;
import hxd.Key;
import hxd.Music;
import hxd.Res;
import dn.Process;

class Main extends hxd.App {
  
  public static var i:Main;
  public static var game:Game;
  public static var menu:MainMenu;
  public static var evo:EvoMenu;
  public static var scav:ScavengeMenu;
  public static var tut:TutorialMenu;
  public static var end:EndingScreen;
  
  public static var delayer:Delayer;
  public static var tw:Tweenie;
  
  static function main() {
    new Main();
  }
  
  override function init()
  {
    i = this;
    delayer = new Delayer(60);
    tw = new Tweenie(60);
    s2d.scaleMode = LetterBox(320, 180, true, Center, Center);
    engine.backgroundColor = 0xff111122;
    #if hl
    Res.initLocal();
    R.init();
    start();
    #else
    var loader:ManifestLoader = ManifestBuilder.initManifest(null, null, "manifest.json");
    new comps.ManifestView(loader, s2d);
    // TODO
    #end
    // menu = new MainMenu();
    // new OverlayText().run("larva");
    #if (sys && hl)
    if (Sys.programPath() == "D:\\Dropbox\\Syncthing\\LudumDare\\LD46\\ld46.hl") {
      @:privateAccess hxd.Window.getInstance().window.setPosition(-1000, 200);
    }
    #end
  }
  
  public function start() {
    new Game();
  }
  
  override function update(dt:Float)
  {
    var tmod = Timer.tmod;
    delayer.update(tmod);
    tw.update(tmod);
    Process.updateAll(tmod);
    super.update(dt);
  }
  
}