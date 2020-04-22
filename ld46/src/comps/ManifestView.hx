package comps;

import h2d.Flow;
import h2d.Animation;
import h2d.ui.ManifestProgress;
import h2d.Object;

class ManifestView extends Object {
  
  public function new(loader, ?parent) {
    super(parent);
    var prog = new ManifestProgress(loader, 0xff303050, handleLoaded, this);
    prog.start();
  }
  
  function handleLoaded() {
    R.init();
    R.glow(50, 50, 0xff222244, this).setPosition(R.W>>1, (R.H>>1) - 3);
    var f = new Flow(this);
    f.horizontalAlign = Middle;
    f.verticalAlign = Middle;
    f.layout = Vertical;
    f.verticalSpacing = 10;
    f.minWidth = R.W;
    f.minHeight = R.H;
    new Animation(Pet.frames(R.unlocks[dn.M.rand(R.unlocks.length)].index()), f);
    // var tut = new Button(R.xsub(0, 90, 68, 13, 3), f);
    var st = new Button(R.xsub(99, 213, 68, 13, 3), f);
    st.onClick = (_)-> {
      remove();
      Main.i.start();
    }
    // Main.i.start();
  }
  
}