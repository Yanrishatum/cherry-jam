package ldx;

import ch2.ui.ManifestProgress;
import h2d.Object;
import cherry.res.ManifestLoader;
import cherry.fs.ManifestBuilder;
import hxd.Res;

class AssetLoader {
  
  var onFinish:Void->Void;
  var loader:ManifestLoader;
  var progress:RedRayLoader;
  
  public static function init(cb:Void->Void) {
    #if (js || test_manifest || test_loader)
    #if (!js && test_loader)
    Res.initLocal();
    #end
    new AssetLoader(cb);
    #else
    Res.initLocal();
    cb();
    #end
  }
  
  public function new(cb:Void->Void) {
    onFinish = cb;
    #if test_loader
    loader = new ManifestLoader(new ldx.RedRayLoader.DummyManifest());
    #else
    loader = ManifestBuilder.initManifest();
    #end
    
    progress = new RedRayLoader(loader, finished);
    State.s2d.add(progress, R.LOADER_LAYER);
    hxd.System.setLoop(render);
  }
  
  function render() {
    hxd.Timer.update();
    State.app.sevents.checkEvents();
    State.s2d.setElapsedTime(hxd.Timer.dt);
    State.engine.render(State.s2d);
  }
  
  function finished() {
    onFinish();
    onFinish = null;
  }
  
}

private class CustomLoader extends ManifestProgress {
  
  public function new(loader, ?color, ?onLoaded, ?parent) {
    super(loader, color, onLoaded, parent);
  }
  
  override function repaint()
  {
    super.repaint();
  }
  
}