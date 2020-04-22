import h2d.Interactive;
import hxd.Res;
import h2d.Bitmap;
import comps.TopButton;
import dn.Process;

class TutorialMenu extends Process {
  
  override public function init()
  {
    super.init();
    Main.tut = this;
    createRoot(Main.i.s2d);
    
    new Interactive(R.W, R.H, root).cursor = Default;
    new Bitmap(Res.tutorial.toTile(), root);
    
    var btn = new TopButton(false, R.xsub(257, 19, 21, 8, 2, 1, 4, 2), root);
    btn.onClick = (_) -> destroy();
    
    btn = new TopButton(true, R.xsub(207, 19, 24, 8, 2, 1, 19, 2), root);
    btn.x = R.W - btn.width;
    btn.onClick = (_) -> {
      if (Main.menu == null || Main.menu.destroyed) Main.menu = new MainMenu();
    }
  }
  
}