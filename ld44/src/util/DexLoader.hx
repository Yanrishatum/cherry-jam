package util;

import h2d.RenderContext;
import h2d.Text;
import h2d.Graphics;
import h2d.Bitmap;
import hxd.res.ManifestLoader;
import h2d.Object;
import hxd.fs.ManifestFileSystem;
// import openfl.display.Bitmap;
// import openfl.display.BitmapData;
// import openfl.display.Preloader;
// import openfl.display.Sprite;

// @:bitmap("assets/intro.png")
// private class Backdrop extends BitmapData {}

/**
 * ...
 * @author Yanrishatum
 */
class DexLoader extends Object
{
  
  var progress:Graphics;
  var fs:ManifestLoader;
  var txt:Text;

  public function new(fs:ManifestLoader, onLoaded:Void->Void, ?parent:Object) 
  {
    super(parent);
    
    progress = new Graphics(this);
    // new Bitmap(hxd.res.Embed.getResource("elements/intro.png").toTile(), this);
    txt = new Text(hxd.res.DefaultFont.get(), this);
    txt.textAlign = Center;
    txt.maxWidth = 800;
    txt.y = 304;
    this.fs = fs;
    
    fs.onLoaded = () -> { onLoaded(); remove(); }
    fs.onFileLoaded = updateDisp;
    fs.onFileProgress = updateProgress;
    fs.onFileLoadStarted = setFile;
    fs.loadManifestFiles();
    // var l = new h2d.ui.ManifestProgress(fs, 0xffafafc8, () -> { onLoaded(); remove(); }, this);
    // l.start();
  }
  
  function setFile(file:LoaderTask)
  {
    var names:Array<String> = [];
    for (t in fs.tasks) {
      if (t.busy) {
        names.push(t.entry.name);
      }
    }
    txt.text = names.join(" | ");
  }
  
  function updateProgress(file:LoaderTask)
  {
    progress.clear();
    progress.beginFill(0xafafc8);
    progress.lineStyle(1, 0);
    progress.drawRect(20, 280, 760 * (fs.loadedFiles / fs.totalFiles), 8);
    for (t in fs.tasks) {
      if (t.busy) {
        progress.drawRect(20, 290+4*t.slot, 760 * (t.loaded / t.total), 3);
      }
    }
  }
  
  function updateDisp(file:LoaderTask)
  {
    updateProgress(file);
  }
  
  override private function drawRec(ctx:RenderContext)
  {
    super.drawRec(ctx);
  }
  
}