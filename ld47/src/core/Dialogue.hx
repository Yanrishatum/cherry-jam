package core;

import h2d.ScaleGrid;
import h2d.col.Point;
import h2d.RenderContext;
import hxd.Timer;
import ch2.ui.effects.Appear;
import hxd.Res;
import h2d.Bitmap;
import ch2.ui.RichText;
import h2d.Object;

class Dialogue extends Object {
  
  var box:ScaleGrid;
  var txt:RichText;
  var app:ShiftAppear;
  var onDone:Void->Void;
  var delay:Float;
  var arrow:Bitmap;
  var target:Object;
  var pointUp:Bool;
  
  public function new(?parent) {
    super(parent);
    app = new ShiftAppear(0, -10);
    app.onFinish = trigger;
    app.cps = 60;
    box = new ScaleGrid(Res.textbox.toTile(), 11, 11, this);
    box.alpha = 0.8;
    txt = new RichText(new RichTextFormat(R.getFont(16), 0xffffffff, 1, Center, null, [app]), this);
    txt.maxWidth = box.tile.width - 30;
    txt.setPosition(15, 5);
    arrow = new Bitmap(Res.textbox_arrow.toTile(), this);
    arrow.rotation = Math.PI * .5;
    arrow.y = box.tile.height - 24;
    arrow.x = box.tile.width - 50;
    arrow.alpha = 0.0;
    visible = false;
  }
  
  public function show(text:String, onDone:Void->Void, pointUp:Bool, target:Object) {
    txt.clear();
    txt.addText(text);
    var s = txt.getSize();
    box.height = s.height + 30;
    txt.y = 12;
    // txt.y = (box.tile.height - s.height) / 2 - 5;
    // app.progress = 0;
    delay = 0.07 * text.length;
    visible = true;
    target = State.game.player;
    this.target = target;
    pointUp = true;
    this.pointUp = pointUp;
    this.onDone = onDone;
    arrow.rotation = Math.PI * (pointUp ? -.5 : .5);
    arrow.y = pointUp ? 24 : box.tile.height - 24;
  }
  
  override function sync(ctx:RenderContext)
  {
    var p = target;
    var pt = new Point(p.x, p.y);
    State.camera.cameraToScene(pt);
    // this.x = pt.x - arrow.x + arrow.tile.width / 2 - 11;
    this.x = pt.x - box.tile.width / 2;
    if (pointUp) this.y = pt.y + arrow.tile.height + 5;
    else this.y = pt.y - arrow.y - arrow.tile.height - 60;
    super.sync(ctx);
  }
  
  function trigger() {
    if (onDone != null) {
      if (delay > 0) {
        delay -= Timer.elapsedTime;
      } else {
        txt.clear();
        var old = onDone;
        onDone = null;
        visible = false;
        old();
      }
    }
  }
  
}