import hxd.Key;
import hxd.Timer;
import h2d.Mask;
import comps.TextView;
import dn.Tweenie;
import hxd.Res;
import h2d.Bitmap;
import h2d.Interactive;
import dn.Process;

class OverlayText extends Process {
  
  var top:Bitmap;
  var bottom:Bitmap;
  static inline final offset = 20;
  var txtMask:Mask;
  var txt:TextView;
  var list:Array<String>;
  var next:Void->Void;
  // var event:String->Void;
  static inline final height = 60;
  
  static var scenes:Map<String, Array<String>>;
  
  override public function init()
  {
    super.init();
    Main.game.pause();
    createRoot(Main.i.s2d);
    var b = new Interactive(R.W, R.H, root);
    b.cursor = Default;
    
    top = new Bitmap(Res.overlay_top.toTile(), root);
    top.y = -top.tile.height;
    this.tw.createS(top.y, -offset, TType.TBackOut, 0.5);
    bottom = new Bitmap(Res.overlay_bot.toTile(), root);
    bottom.y = R.H;
    this.tw.createS(bottom.y, R.H - bottom.tile.height+offset, TType.TBackOut, 0.5);
    
    if (scenes == null) {
      updateScenes();
      #if debug
      Res.texts.scenes.watch(updateScenes);
      #end
    }
    
    txtMask = new Mask(147, height, root);
    txtMask.setPosition(85, 112);
    txt = new TextView(txtMask);
    // txt.setPosition(86, 113);
    txt.setPosition(1, 1);
    txt.speed = 0.5;
    txt.onDone = delayer.addS.bind("scene", showNext, 1);
  }
  
  public function run(id:String, ?next:Void->Void) {
    // trace(id, next);
    this.next = next;
    delayer.addS("timer", () -> {
      list = scenes.get(id).copy();
      txt.show(list.shift());
    }, 0.8);
  }
  
  function showNext() {
    if (list.length == 0) {
      delayer.addS("exit", () -> {
        this.tw.createS(top.y, -top.tile.height, TType.TBurnIn, 0.5);
        this.tw.createS(txtMask.y, txtMask.y+bottom.tile.height+offset, TType.TBurnIn, 0.5);
        this.tw.createS(bottom.y, R.H, TType.TBurnIn, 0.5).onEnd = () -> {
          // trace(next);
          if (next != null) next();
          destroy();
        }
      }, 1.5);
      return;
    }
    txt.append("\n" + list.shift());
  }
  
  override public function update()
  {
    if (txt.txt.textHeight + txt.y > height) {
      txt.y -= Timer.dt * 120;
    }
    if (Key.isReleased(Key.ESCAPE)) {
      if (next != null) next();
      destroy();
    }
    super.update();
  }
  
  static function updateScenes() {
    var s = Res.texts.scenes.entry.getText().split("\n");
    var i = 0;
    var tag:Int = -1;
    var tagn:String = null;
    scenes = [];
    while (i < s.length) {
      var v = s[i++];
      if (v.charCodeAt(0) == "#".code) {
        if (tagn != null) scenes[tagn] = s.slice(tag, i-1);
        tag = i;
        tagn = StringTools.trim(v.substr(1));
      }
    }
    scenes[tagn] = s.slice(tag, i);
  }
  
  override public function onDispose()
  {
    Main.game.resume();
    super.onDispose();
  }
  
}