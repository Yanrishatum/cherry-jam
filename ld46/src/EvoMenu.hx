import h2d.Animation;
import h2d.Text;
import State;
import hxd.Res;
import h2d.Bitmap;
import h2d.Interactive;
import dn.Process;
import comps.*;
import State.Evolution;

class EvoMenu extends Process {
  
  var preview:Animation;
  var emotes:Array<LButton>;
  var info:Text;
  
  override public function init()
  {
    super.init();
    createRoot(Main.i.s2d);
    var cover = new Interactive(R.W, R.H, root);
    cover.cursor = Default;
    new Bitmap(Res.evo_bg.toTile(), root);
    
    var btn = new TopButton(false, R.xsub(257, 19, 21, 8, 2, 1, 4, 2), root);
    btn.onClick = (_) -> destroy();
    
    btn = new TopButton(true, R.xsub(207, 19, 24, 8, 2, 1, 19, 2), root);
    btn.x = R.W - btn.width;
    btn.onClick = (_) -> {
      if (Main.menu == null || Main.menu.destroyed) Main.menu = new MainMenu();
    }
    
    emotes = [];
    
    preview = new Animation(null, root);
    preview.x = 34+186;
    preview.y = 42+19;
    
    inline function btn(name:Evolution, x:Float, y:Float) {
      var b = new EvoButton(name, root);
      b.setPosition(x, y);
      
      b.onOver = (_) -> {
        if (!b.flags.has(Disabled)) showEvo(name);
      }
    }
    btn(EvoBase, 18, 73);
    btn(EvoGood, 56, 54);
    btn(EvoBad, 56, 92);
    btn(EvoGood2, 94, 35);
    btn(EvoNeutral, 94, 73);
    btn(EvoBad2, 94, 111);
    btn(EvoHealer, 132, 16);
    btn(EvoGuard, 132, 54);
    btn(EvoSoldier, 132, 92);
    btn(EvoPredator, 132, 130);
    
    info = R.txt(root, [ 0xffffff => 0xff8888aa, 0x090910 => 0xff222233 ]);
    info.lineSpacing = 1;
    info.setPosition(189, 116);
    
    showEvo(EvoBase);
  }
  
  function showEvo(evo:Evolution) {
    var conf = State.i.getEvo(evo);
    var fr = Pet.frames(conf.index);
    for (f in fr) f.tile.setCenterRatio();
    preview.play(fr);
    // preview.tile = if (conf.index > 5) (R.b.sub(0, 294 + 53 * (conf.index-6), 34, 52)).center();
    //   else (R.b.sub(0, 49 * conf.index, 32, 48)).center();
    for (e in emotes) e.remove();
    emotes = [];
    var i = 0;
    for (e in conf.emotions) {
      if (e == Dying) continue;
      var index = e.toIndex();
      var b = new LButton([
        R.xsub(70, 55, 28, 20, 2),
        [R.a.sub(157 + 23 * (index % 8), 55 + 15 * Std.int(index / 8), 22, 14, 3, 3)]
      ], root);
      b.setPosition(261, 32 + 24 * i++);
      b.onClick = makeSound.bind(_, index);
      emotes.push(b);
    }
    info.text = conf.name.toUpperCase() + "\n- " + conf.info.join("\n- ");
  }
  
  function makeSound(_, idx) {
    R.s(Res.load("sound/em/sfx_" + @:privateAccess Pet.EMOTE_SFX[idx] + ".mp3").toSound());
  }
  
}