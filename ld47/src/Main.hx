package;

import hxd.Window;
import scenes.CutsceneScene;
import hxd.Res;
import scenes.GameScene;
import h2d.RenderContext;
import h3d.Engine;
import scenes.MenuScene;
import cherry.Music;
import ldx.AssetLoader;

class Main extends hxd.App {
  
  static function main() {
    #if js
    js.Browser.document.getElementById("script-loader-container").remove();
    #end
    new Main();
  }
  
  #if hlimgui
  var im:imgui.ImGuiDrawable;
  #end
  
  override function loadAssets(onLoaded:() -> Void)
  {
    #if (sys && debug)
    if (Sys.getEnv("USERNAME") == "yanrishatum") {
      @:privateAccess State.window.window.setPosition(-1300, 200);
    }
    #end
    
    State.app = this;
    engine.backgroundColor = 0xff282828;
    AssetLoader.init(onLoaded);
  }
  
  static var assetsInitialized:Bool = false;
  public static function initAssets() {
    if (!assetsInitialized) {
      R.init();
      L.init();
      State.init();
      assetsInitialized = true;
    }
  }
  
  override function init()
  {
    #if hlimgui
    s2d.add(new ImguiHack(), 100);
    s2d.add(im = new imgui.ImGuiDrawable(s2d), 100);
    #end
    s2d.defaultSmooth = true;
    s2d.scaleMode = LetterBox(1280, 720, false, Center, Center);
    #if js
    Window.getInstance().useScreenPixels = true;
    #end
    // Utils.bgColor(0xff554f6b);
    initAssets();
    // var fps = new ch2.ui.FPS();
    // s2d.add(fps, R.LOADER_LAYER);
    // var loader = Type.createEmptyInstance(cherry.res.ManifestLoader);
    // new ldx.RedRayLoader(loader, () -> trace("yay"), s2d);
    // new MenuScene();
    #if (sys && debug)
    // if (Sys.getEnv("USERNAME") == "yanrishatum") {
    //     new CutsceneScene();
    // } else 
    #end
    #if js
    CutsceneScene.showIntro();
    #else
    new GameScene();
    #end
    
  }
  
  override function onResize()
  {
    #if hlimgui
    imgui.ImGui.setDisplaySize(s2d.width, s2d.height);
    #end
    super.onResize();
  }
  
  override function mainLoop()
  {
    
    #if hlimgui
    im.update(s2d.renderer.elapsedTime);
    imgui.ImGui.newFrame();
    #end
    super.mainLoop();
    
  }
  
  override function update(dt:Float)
  {
    dn.Process.updateAll(hxd.Timer.tmod);
  }
  
  override public function render(e:Engine)
  {
    super.render(e);
    
  }
  
}

#if hlimgui
private class ImguiHack extends h2d.Object {
  
  override function sync(ctx:RenderContext)
  {
    super.sync(ctx);
    #if hlimgui
    imgui.ImGui.render();
    #end
  }
  
}
#end