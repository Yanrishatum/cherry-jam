package comps;

import hxd.Rand;
import hxd.Timer;
import dn.Process;
import h2d.RenderContext;
import h2d.Mask;
import h2d.Bitmap;
import State.StatName;
import h2d.Object;

class StatView extends Object {
  
  var stat:StatName;
  var slider:VSlider;
  
  public function new(stat:StatName, index:Int, ?parent)
  {
    super(parent);
    this.stat = stat;
    new Bitmap(R.a.sub(13 * index, 30, 12, 12), this);
    new Bitmap(R.a.sub(0, 43, 44, 6), this).setPosition(12, 3);
    slider = new VSlider(index, this);
    slider.setPosition(13, 4);
  }
  
  override function sync(ctx:RenderContext)
  {
    slider.floating = stat == Hunger ? State.i.stage == 0 : (stat == Humanity ? State.i.stage < 2 : false);
    slider.set(State.i.stats.get(stat) / 100); // TODO: Max
    super.sync(ctx);
  }
  
}

class VSlider extends Mask {
  
  var line:Bitmap;
  var caret:Bitmap;
  
  var curr:Float;
  var target:Float;
  public var floating:Bool;
  var floatBase:Float;
  var floatBar:Bitmap;
  
  public function new(index:Int, parent) {
    super(42, 4, parent);
    line = new Bitmap(R.a.sub(9 * index + 1, 50, 1, 4), this);
    caret = new Bitmap(R.a.sub(9 * index + 4, 50, 4, 4), this);
    floatBar = new Bitmap(R.a.sub(36, 50, 11, 4), this);
    curr = 0;
    target = -1;
  }
  
  public function set(ratio:Float) {
    if (ratio != this.target) {
      this.target = ratio;
      floatBase = Math.random() * .1 - .05;
    }
  }
  
  override function sync(ctx:RenderContext)
  {
    var t = target;
    if (t > curr) {
      curr += Timer.dt*1.5;
      if (t < curr) curr = t;
      update();
    } else if (t < curr) {
      curr -= Timer.dt*1.5;
      if (t > curr) curr = t;
      update();
    }
    floatBar.visible = floating;
    super.sync(ctx);
  }
  
  function update() {
    line.scaleX = width * curr;
    caret.x = line.scaleX;
    floatBar.x = caret.x - (floatBar.width * .5) * floatBase;
  }
  
}