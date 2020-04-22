import h2d.Animation;
import comps.Pet;
import comps.Button;
import hxd.Res;
import h2d.Bitmap;
import h2d.Interactive;
import dn.Process;

class EndingScreen extends Process {
  
  override public function init()
  {
    Main.end = this;
    Main.game.pause();
    super.init();
    createRoot(Main.i.s2d);
    
    new Interactive(R.W, R.H, root).cursor = Default;
    new Bitmap(Res.end_bg.toTile(), root);
    
    var res = new Button(R.xsub(0, 104, 68, 13, 3), root);
    res.onClick = (_) -> {
      destroy();
      if (Main.scav != null && !Main.scav.destroyed) Main.scav.destroy();
      if (Main.tut != null && !Main.tut.destroyed) Main.tut.destroy();
      new Game();
    }
    res.setPosition((R.W-res.width)*.5, 160);
    
    var txt = R.txt(root);
    txt.textAlign = MultilineCenter;
    txt.setPosition(100, 42);
    txt.text = 'Your morphling has fully evolved\ninto a ${State.i.currEvo().name}!';
    
    txt = R.txt(root);
    txt.textAlign = Center;
    txt.maxWidth = R.W;
    txt.text = 'Forms unlocked: ${R.unlocks.length}/10';
    txt.y = 130;
    
    var anim = new Animation(Pet.frames(State.i.evo.index()), root);
    anim.x = 60;
    anim.y = 30;
    
  }
  
}