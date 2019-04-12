package engine.utils;

import h2d.Text;
import hxd.Event;
import hxd.BitmapData;
import h2d.RenderContext;
import h2d.Tile;
import h2d.Graphics;
import h2d.Interactive;
import h2d.Object as Sprite;
import hxd.res.DefaultFont;
import h2d.Font;
import h2d.Flow;

class DebugDisplay
{
  
  public static var font:Font;
  
  public static var flow:Flow;
  
  private static var groupStack:Array<Flow>;
  private static var group:Flow;
  
  private static var active:Bool;
  
  public static function init():Void
  {
    active = true;
    groupStack = new Array();
    font = DefaultFont.get();
    flow = new h2d.Flow(HXP.engine.s2d);
    flow.layout = Vertical;
    flow.verticalSpacing = 2;
  }
  
  public static function beginGroup(label:String, visible:Bool, vertical:Bool = true):Flow
  {
    if (!active) return null;
    if (group != null)
    {
      groupStack.push(group);
    }
    var g:Flow = new Flow();
    g.layout = vertical ? Vertical : Horizontal;
    g.verticalSpacing = 2;
    g.paddingLeft = 10;
    addCheckbox(label, visible, function(v:Bool):Void { g.visible = v; });
    if (group != null) group.addChild(g);
    else flow.addChild(g);
    g.visible = visible;
    group = g;
    return g;
  }
  
  public static function endGroup():Void
  {
    if (groupStack.length > 0) group = groupStack.pop();
    else group = null;
  }
  
  private static function makeEntry(label:String, ?comps:Array<Sprite>):Flow
  {
    if (!active) return null;
    var f:Flow = new Flow(group != null ? group : flow);
    f.horizontalSpacing = 5;
  
    var tf = new h2d.Text(font, f);
    if (label != null) tf.text = label;
    tf.maxWidth = 70;
    tf.textAlign = Right;
    
    if (comps != null)
    {
      for (comp in comps)
      {
        f.addChild(comp);
      }
    }
    return f;
  }
  
  public static function addButton(label:String, click:Void->Void)
  {
    var b:Button = new Button(100, 20, label);
    b.onClick = (e) -> click();
    
    makeEntry(null, [b]);
    return b;
  }
  
  public static function addCheckbox(label:String, value:Bool, set:Bool->Void)
  {
    if (!active) return null;
    var i:Checkbox = new Checkbox();
    i.checked = value;
    i.onChange = set;
    
    makeEntry(label, [i]);
    return i;
  }
  
  public static function addSliderF( label : String, get : Void -> Float, set : Float -> Void, min : Float = 0., max : Float = 1. ) {
    
    if (!active) return null;
    var f:Flow = makeEntry(label);
    
    var sli = new h2d.Slider(200, 10, f);
    sli.minValue = min;
    sli.maxValue = max;
    sli.value = get();

    var tf = new h2d.TextInput(font, f);
    tf.text = "" + hxd.Math.fmt(sli.value);
    sli.onChange = function() {
      set(sli.value);
      tf.text = "" + hxd.Math.fmt(sli.value);
      f.needReflow = true;
    };
    tf.onChange = function() {
      var v = Std.parseFloat(tf.text);
      if( Math.isNaN(v) ) return;
      sli.value = v;
      set(v);
    };
    
    return sli;
  }
  
}

class Button extends Interactive
{
  private var bg:Tile;
  private var hover:Tile;
  private var down:Tile;
  
  private var pressed:Bool;
  
  public function new(w:Int, h:Int, label:String, ?parent:Sprite)
  {
    super(w, h, parent);
    var txt:Text = new Text(DebugDisplay.font, this);
    txt.maxWidth = w;
    txt.textAlign = Align.Center;
    txt.text = label;
    txt.x = 0;
    txt.y = (h - txt.textHeight) / 2;
    txt.color.setColor(0xffffffff);
    
    bg = Tile.fromColor(0x808080, w, h);
    hover = Tile.fromColor(0xA0A0A0, w, h);
    down = Tile.fromColor(0x606060, w, h);
    
  }
  
  override private function draw(ctx:RenderContext)
  {
    if (isOver())
    {
      emitTile(ctx, pressed ? down : hover);
    }
    else 
    {
      emitTile(ctx, pressed ? hover : bg);
    }
    super.draw(ctx);
  }
  
  override public function handleEvent(e:Event)
  {
    if (e.kind == EventKind.EPush)
    {
      pressed = true;
    }
    else if (e.kind == EventKind.ERelease || e.kind == EventKind.EReleaseOutside)
    {
      pressed = false;
    }
    super.handleEvent(e);
  }
  
}

class Checkbox extends Interactive
{
  private static var bg:Tile;
  private static var check:Tile;
  
  public var checked:Bool;
  
  public function new(?parent:Sprite)
  {
    super(10, 10, parent);
    if (bg == null)
    {
      bg = Tile.fromColor(0x808080, 10, 10);
      var d:BitmapData = new BitmapData(8, 8);
      d.setPixel(7, 1, 0xffCCCCCC);
      d.setPixel(6, 2, 0xffCCCCCC);
      d.setPixel(5, 3, 0xffCCCCCC);
      d.setPixel(4, 4, 0xffCCCCCC);
      d.setPixel(3, 5, 0xffCCCCCC);
      d.setPixel(2, 6, 0xffCCCCCC);
      d.setPixel(1, 5, 0xffCCCCCC);
      d.setPixel(0, 4, 0xffCCCCCC);
      
      check = Tile.fromBitmap(d);
      check.dx = 1;
      check.dy = 1;
    }
  }
  
  override private function draw(ctx:RenderContext)
  {
    super.draw(ctx);
    emitTile(ctx, bg);
    if (checked) emitTile(ctx, check);
  }
  
  override public function handleEvent(e:Event)
  {
    super.handleEvent(e);
    if (e.cancel) return;
    switch(e.kind)
    {
      case ERelease:
        checked = !checked;
        onChange(checked);
      default:
    }
  }
  
  public dynamic function onChange(value:Bool):Void
  {
    
  }
}