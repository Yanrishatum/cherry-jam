package comps;

import hxd.Timer;
import h2d.RenderContext;
import h2d.Object;
import h2d.Text;

class TextView extends Object {
  
  public var txt:Text;
  var caret:Float;
  var text:String;
  public var speed:Float = 1;
  
  public function new(?parent) {
    super(parent);
    txt = R.txt(this);
    txt.maxWidth = 145;
    txt.textAlign = Center;
    // setPosition(86, 138);
  }
  
  public function show(text:String) {
    this.text = txt.splitText(StringTools.replace(text, "\r", ""));
    caret = 0;
    this.txt.text = "";
  }
  
  public function append(text:String) {
    if (this.text == null) this.text = "";
    this.text = txt.splitText(this.text + StringTools.replace(text, "\r", ""));
  }
  
  override function sync(ctx:RenderContext)
  {
    if (text != null && caret < text.length) {
      // caret += Timer.dt * 120;
      caret += hxd.Timer.tmod * speed;
      this.txt.text = text.substr(0, Std.int(caret));
      if (caret > text.length) {
        caret = text.length;
        onDone();
      }
    }
    super.sync(ctx);
  }
  
  public dynamic function onDone() {
    
  }
  
}