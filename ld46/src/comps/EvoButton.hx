package comps;

import hxd.Key;
import hxd.Event;
import h2d.Bitmap;
import State;
import h2d.ui.CustomButton;

class EvoButton extends LButton {
  
  var ename:Evolution;
  var conf:EvoConfig;
  
  public function new(name:Evolution, ?parent) {
    ename = name;
    conf = State.i.getEvo(name);
    var portraits = R.ysub(35 * conf.index, 146, 34, 31, 2, 4, 0, 0);
    super([
      R.xsub(0, 55, 34, 34, 2),
      [portraits[0]]
    ], parent);
    addFlags(Disabled, [
      R.xsub(0, 55, 34, 34, 2),
      [portraits[1]]
    ]);
    // #if !debug
    setFlag(Disabled, R.unlocks.indexOf(name) == -1);
    // #end
    var t = R.a.sub(39, 30, 4, 5);
    if (conf.leafs.length == 2 && R.unlocks.indexOf(name) != -1) {
      if (R.unlocks.indexOf(conf.leafs[0]) != -1) new Bitmap(t, this).setPosition(34, 5);
      if (R.unlocks.indexOf(conf.leafs[1]) != -1) new Bitmap(t, this).setPosition(34, 24);
    }
  }
  
  override public function onClick(e:Event)
  {
    if (Key.isDown(Key.SHIFT) && !flags.has(Disabled) && ename.stage() != 3) {
      Main.evo.destroy();
      new Game(ename);
    }
  }
  
}