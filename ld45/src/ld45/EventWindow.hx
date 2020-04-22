package ld45;

import hxd.Res;
import h2d.ScaleGrid;
import hxd.Event;
import ld45.State;
import h2d.Flow;
import h2d.ui.Button;
import hxd.res.DefaultFont;
import h2d.Interactive;
import h2d.Text;
import h2d.Object;

class EventWindow extends Object
{
  
  var lock:Interactive;
  var backdrop:ScaleGrid;
  var text:Text;
  var confirm:Interactive;
  var deny:Interactive;
  var flow:Flow;
  var btnFlow:Flow;
  
  var queue:Array<TileType>;
  var cur:EventConfig;
  
  var custom:{ text:String, onOk:Void->Void, onCancel:Void->Void };
  
  public function new(parent)
  {
    super(parent);
    lock = new Interactive(1280, 720, this);
    lock.cursor = Default;
    
    backdrop = new ScaleGrid(Res.textures.ui.quest_backdrop_64x.toTile(), 64, 64, this);
    var f = flow = new Flow(this);
    f.minWidth = 64*3;
    f.minHeight = 64*2;
    f.padding = 20;
    f.verticalSpacing = 20;
    f.layout = Vertical;
    f.horizontalAlign = Middle;
    f.verticalAlign = Bottom;
    text = new Text(Util.yadaEvent(), f);
    text.maxWidth = 400;
    text.dropShadow = { dx: 1, dy: 1, color: 0, alpha: 0.5 };
    f = btnFlow = new Flow(f);
    f.horizontalSpacing = 10;
    confirm = Util.button("Yes", Res.textures.ui.button_idle, Res.textures.ui.button_over, Res.textures.ui.button_press, f);
    confirm.onClick = confirmClick;
    deny = Util.button("No", Res.textures.ui.button_idle, Res.textures.ui.button_over, Res.textures.ui.button_press, f);
    deny.onClick = denyClick;
    queue = [];
    visible = false;
  }
  
  public function showCustom(text:String, ok:Void->Void, cancel:Void->Void)
  {
    custom = { text: text, onOk: ok, onCancel: cancel };
    activate();
  }
  
  public function show(type:TileType)
  {
    custom = null;
    if (cur != null)
    {
      queue.push(type);
      return;
    }
    var d:TileBalance = Reflect.field(State.config.tiles, type.getName());
    if (d.events != null && d.events.length > 0)
    {
      var evs:Array<EventConfig> = [];
      // trace(d.events);
      for (e in State.config.events)
      {
        if (d.events.indexOf(e.id) != -1 && State.humans >= e.min_population)
        {
          // trace(e.id);
          evs.push(e);
        }
      }
      // trace(evs);
      if (evs.length > 0)
      {
        cur = evs[Std.int(Math.random() * evs.length)];
      }
    }
    if (cur != null) activate();
  }
  
  function activate()
  {
    SoundSystem.play(Res.sfx.ld_sfx_event);
    if (custom != null)
    {
      this.text.text = custom.text;
      if (custom.onCancel == null) deny.remove();
      else btnFlow.addChild(deny);
    }
    else 
    {
      this.text.text = cur.text;
      if (cur.deny == null) deny.remove();
      else btnFlow.addChild(deny);
    }
    visible = true;
    backdrop.width = flow.outerWidth;
    backdrop.height = flow.outerHeight;
    backdrop.x = flow.x = Math.round((1280 - backdrop.width) / 2);
    backdrop.y = flow.y = Math.round((720 - backdrop.height) / 2);
  }
  
  function next()
  {
    cur = null;
    State.ui.step();
    if (queue.length != 0)
    {
      show(queue.shift());
      return;
    }
    State.capResources();
    visible = false;
  }
  
  function confirmClick(e:Event)
  {
    if (custom != null)
    {
      custom.onOk();
      visible = false;
      return;
    }
    for (res in cur.accept)
    {
      State.gain(res);
    }
    next();
    
  }
  
  function denyClick(e:Event)
  {
    if (custom != null)
    {
      custom.onCancel();
      visible = false;
      return;
    }
    for (res in cur.deny)
    {
      State.gain(res);
    }
    next();
  }
  
  
  
}