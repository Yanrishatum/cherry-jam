package game.comps;

import hxd.Event;
import h2d.Graphics;
import h2d.Font;
import engine.HXP;
import h2d.Text;
import h2d.Slider;
import hxd.Res;
import h2d.Interactive;
import h2d.Flow;
import h2d.Object as Sprite;

class SettingsWindow extends Interactive
{
  private var atb:Array<Radio>;
  
  public function new(?parent:Sprite)
  {
    var bgt = Res.settings.toTile();
    super(bgt.width, bgt.height, parent);
    cursor = Default;
    new h2d.Bitmap(bgt, this);
    var f:Flow = new Flow(this);
    f.minWidth = bgt.iwidth;
    f.minHeight = bgt.iheight;
    f.layout = Vertical;
    f.verticalSpacing = 5;
    f.horizontalAlign = Middle;
    f.verticalAlign = Middle;
    
    var h:Flow = null;
    inline function lbl(label:String)
    {
      h = new Flow(f);
      h.horizontalSpacing = 5;
      h.verticalAlign = Middle;
      if (label != null)
      {
        var txt:Text = new Text(GameUI.elmessiri14, h);
        txt.text = label;
        txt.maxWidth = 100;
        txt.textAlign = Right;
        txt.color.setColor(GameUI.color);
      }
    }
    
    lbl("SFX volume:");
    var sfx:Slider = new Slider(200, 20, h);
    sfx.minValue = 0;
    sfx.maxValue = 1;
    sfx.value = HXP.sfxChannel.volume;
    sfx.onChange = function() {
      HXP.sfxChannel.volume = sfx.value;
    }
    
    lbl("Music volume:");
    var music:Slider = new Slider(200, 20, h);
    music.minValue = 0;
    music.maxValue = 1;
    music.value = HXP.musicChannel.volume;
    music.onChange = function() {
      HXP.musicChannel.volume = music.value;
    }
    
    lbl("ATB Speed:");
    
    var radio:Radio = new Radio("Slow", GameUI.elmessiri14, null, h);
    radio.onChange = changeSpeed;
    atb = radio.group;
    new Radio("Normal", GameUI.elmessiri14, atb, h).onChange = changeSpeed;
    new Radio("Fast", GameUI.elmessiri14, atb, h).onChange = changeSpeed;
    for (r in atb) r.txt.color.setColor(GameUI.color);
    
    if (Main.atbSpeed == 1) atb[1].selected = true;
    else if (Main.atbSpeed < 1) atb[0].selected = true;
    else atb[2].selected = true;
    
    this.x = (1280 - bgt.width) / 2;
    this.y = (720 - bgt.height) / 2;
    
    var close:Interactive = new Interactive(40, 40, this);
    close.onClick = (_) -> { GameUI.click(); remove(); }
    close.x = 572;
    close.y = 8;
  }
  
  private function changeSpeed():Void
  {
    if (atb[0].selected)
    {
      Main.atbSpeed = 0.5;
    }
    else if (atb[1].selected)
    {
      Main.atbSpeed = 1;
    }
    else 
    {
      Main.atbSpeed = 2;
    }
  }
  
}

class Radio extends Interactive
{
  
  public var txt:Text;
  public var group:Array<Radio>;
  private var g:Graphics;
  private var yOff:Float;
  
  private var _sel:Bool;
  public var selected(get, set):Bool;
  private inline function get_selected():Bool { return _sel; }
  private function set_selected(v:Bool):Bool
  {
    if (v)
    {
      _sel = true;
      for (r in group) if (r != this) r.selected = false;
      redraw();
      return v;
    }
    else 
    {
      _sel = false;
      redraw();
      return v;
    }
  }
  
  public dynamic function onChange() {
    
  }
  
  public function new(label:String, font:Font, group:Array<Radio>, ?parent)
  {
    txt = new Text(font);
    txt.text = label;
    txt.x = 14;
    if (group == null) group = [this];
    else group.push(this);
    this.group = group;
    
    super(14 + txt.textWidth, HXP.max(10, Math.ceil(txt.textHeight)), parent);
    if (height > 10) yOff = (height - 10) / 2;
    else yOff = 0;
    addChild(txt);
    g = new Graphics(this);
    g.drawCircle(5, 5, 10);
  }
  
  private function redraw():Void
  {
    g.clear();
    g.beginFill(0xCCCCCC);
    g.drawCircle(5, 5+yOff, 5);
    if (_sel)
    {
      g.beginFill(0);
      g.drawCircle(5, 5+yOff, 2.5);
    }
    g.endFill();
  }
  
  override public function handleEvent(e:Event)
  {
    super.handleEvent(e);
    switch(e.kind)
    {
      case ERelease:
        if (!selected)
        {
          selected = true;
          onChange();
        }
      default:
        
    }
    // swithc(e.kind)
    // {
    //   case ERelease:
    //     
    //   default:
        
    // }
  }
  
}