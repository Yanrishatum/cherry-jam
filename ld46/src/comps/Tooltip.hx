package comps;

import h2d.ui.EventInteractive;
import State;
import h2d.Interactive;
import h2d.RenderContext;
import h2d.Bitmap;
import h2d.ScaleGridExt;
import h2d.Object;
import h2d.Text;

class Tooltip extends Object {
  
  public static function makeInter(text:String, w:Int, h:Int, ?parent) {
    var inter = new Interactive(w, h, parent);
    var tt = new Tooltip(text, inter);
    inter.onOver = (_) -> tt.show();
    inter.onOut = (_) -> tt.hide();
    return { inter: inter, tooltip: tt };
  }
  
  public static function bindResource(tt:Tooltip, res:ActionName, ?notEnough:String) {
    tt.onShow = () -> tt.updateText(notEnough != null && State.i.resources[res] < 1 ? notEnough : res.name() + ": " + State.i.resources[res]);
    return tt;
  }
  
  public static function attach(text:String, el:EventInteractive) {
    var tt = new Tooltip(text, el);
    el.onOverEvent.add((_) -> tt.show());
    el.onOutEvent.add((_) -> tt.hide());
    return tt;
  }
  
  var txt:Text;
  var grid:ScaleGridExt;
  var tip:Bitmap;
  
  public function new(text:String, ?parent) {
    super(parent);
    grid = new h2d.ScaleGridExt(R.a.sub(195, 119, 11, 11), 4, 4, 4, 4, this);
    
    tip = new Bitmap(R.a.sub(207, 125, 5, 6), this);
    tip.scaleX = -1;
    
    txt = R.txt(this);
    txt.setPosition(5, 5);
    txt.textAlign = MultilineCenter;
    txt.maxWidth = 120;
    visible = false;
    updateText(text);
  }
  
  public function updateText(text:String) {
    txt.text = text;
    grid.setSize(Std.int(txt.textWidth + 11), Std.int(txt.textHeight + 11));
    tip.y = grid.height - 2;
  }
  
  public function show() {
    visible = true;
    onShow();
  }
  
  public function hide() {
    visible = false;
  }
  
  public dynamic function onShow() {
    
  }
  
  override function sync(ctx:RenderContext)
  {
    if (visible) {
      syncPos();
      var x = Main.i.s2d.mouseX - (grid.width >> 1);
      if (x < 0) x = 0;
      else if (x + grid.width > R.W) x = R.W - grid.width;
      this.absX = x;
      this.absY = Main.i.s2d.mouseY - grid.height - tip.tile.height + 2;
      txt.calcAbsPos();
      grid.calcAbsPos();
      tip.x = Main.i.s2d.mouseX - x;
      if (tip.x < tip.tile.width+2) tip.x = tip.tile.width+2;
      else if (tip.x + tip.tile.width >= grid.width) tip.x = grid.width - tip.tile.width;
    }
    super.sync(ctx);
  }
  
}