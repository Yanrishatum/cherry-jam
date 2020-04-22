import h2d.Bitmap;
import h2d.Interactive;
import hxd.Res;
import h2d.Flow;
import dn.Process;
import comps.*;

class MainMenu extends Process {
  
  var info:Interactive;
  
  override public function init()
  {
    super.init();
    createRoot(Main.i.s2d);
    var drop = new Interactive(R.W, R.H, root);
    drop.cursor = Default;
    drop.backgroundColor = 0xff111133;
    drop.alpha = 0.66;
    var r = new Flow(root);
    r.backgroundTile = Res.menu_bg.toTile();
    r.layout = Vertical;
    r.verticalSpacing = 6;
    r.paddingHorizontal = 10;
    r.paddingTop = 10;
    
    var tut = new Button(R.xsub(0, 90, 68, 13, 3), r);
    tut.onClick = (_) -> {
      destroy();
      if (Main.tut == null || Main.tut.destroyed) new TutorialMenu();
    }
    new VolumeSlider(false, r);
    new VolumeSlider(true, r);
    var res = new Button(R.xsub(0, 104, 68, 13, 3), r);
    r.addSpacing(1);
    res.onClick = (_) -> {
      destroy();
      if (Main.scav != null && !Main.scav.destroyed) Main.scav.destroy();
      if (Main.tut != null && !Main.tut.destroyed) Main.tut.destroy();
      new Game();
    }
    
    var title = new Button(R.xsub(0, 118, 64, 13, 3), r);
    title.onClick = (_) -> {
      info.visible = !info.visible;
    }
    r.getProperties(title).align(Middle, Middle);
    r.addSpacing(21-7);
    
    var close = new Button(R.xsub(0, 132, 14, 13, 3), r);
    close.onClick = function(_) destroy();
    r.getProperties(close).align(Middle, Middle);
    r.addSpacing(7);
    r.x = Math.ffloor((R.W - r.backgroundTile.width) / 2);
    r.y = Math.ffloor((R.H - r.backgroundTile.height) / 2) - 1;
    info = new Interactive(88, 84, root);
    new Bitmap(Res.info.toTile(), info);
    info.setPosition(r.x, r.y);
    info.cursor = Default;
    info.visible = false;
  }
  
}