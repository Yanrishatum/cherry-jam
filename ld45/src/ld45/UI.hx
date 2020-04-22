package ld45;

import h2d.ScaleGrid;
import h2d.Flow;
import h2d.Bitmap;
import h2d.Object;
import h2d.HtmlText;
import h2d.ui.SimpleButton;
import hxd.Res;
import hxd.res.DefaultFont;
import h2d.Text;
import hxd.Event;
import h2d.ui.Button;
import h2d.Interactive;

class UI extends h2d.Object {
  
  public var camp:SimpleButton;
  
  var uiDrop:Bitmap;
  var people:Text;
  var food:Text;
  var water:Text;
  var clothing:Text;
  var instruments:Text;
  
  var menuUI:UIMenu;
  public var credits:Object;
  
  public function new(parent)
  {
    super(parent);
    uiDrop = new Bitmap(Res.textures.ui.ui.toTile(), this);
    uiDrop.x = 32;
    uiDrop.y = 720 - 32 - uiDrop.tile.height;
    var w = uiDrop.tile.width;
    var campBtn = new Object(uiDrop);
    var campDisabled = new Interactive(96, 96, campBtn);
    campDisabled.addChild(new h2d.Bitmap(Res.textures.ui.icon_camp_unable.toTile()));
    campDisabled.cursor = Default;
    var b = Util.button("", Res.textures.ui.icon_camp_able, Res.textures.ui.icon_camp_over, Res.textures.ui.icon_camp_press, Res.textures.ui.icon_camp_unable, campBtn);// new Button(100, 100, "CAMP", this);
    campBtn.x = w - b.width;
    camp = b;
    camp.onClick = campClick;
    function showIcon(_)
    {
      var str = StringTools.replace(Const.CAMP_TIP, "\n", "<br/>");
      if (!camp.visible) str += StringTools.replace(Const.CAMP_NOPE, "\n", "<br/>");
      GameMap.current.tileInfo.showTextAt(str, campBtn.absX + b.width, campBtn.absY - 10, Right, Bottom);
    }
    function hideIcon(_) { GameMap.current.tileInfo.hide(); }
    campDisabled.onOver = showIcon;
    campDisabled.onOut = hideIcon;
    camp.onOver = showIcon;
    camp.onOut = hideIcon;
    
    var shadow = { dx: 1., dy: 1., color: 0, alpha: 1. };
    function ldFont(name:String) return Util.yadaUi();
    function txt(x:Float, oneline:Bool = false)
    {
      var t = new HtmlText(Util.yadaEvent(), uiDrop);
      t.loadFont = ldFont;
      // t.dropShadow = shadow;
      t.text = oneline ? "RES" : "RES<br/><font face='ui'>MAX</font>";
      t.textColor = 0xbb7744;//0xaa6633;
      t.setPosition(x, Math.floor((uiDrop.tile.height - t.textHeight) / 2));
      return t;
    }
    people = txt(195, true);
    food = txt(406);
    water = txt(570);
    clothing = txt(740);
    instruments = txt(928);
    
    menuUI = new UIMenu(this);
    menuUI.x = 32;
    menuUI.y = uiDrop.y - menuUI.getBounds().height;
    menuUI.visible = false;
    var menu = Util.button("", Res.textures.ui.icon_menu, Res.textures.ui.icon_menu_over, Res.textures.ui.icon_menu_press, null, uiDrop);
    menu.onClick = function(_) menuUI.visible = !menuUI.visible;
    
    var f = new Flow(this);
    f.maxWidth = 1280;
    f.maxHeight = 720;
    f.fillWidth = true;
    f.fillHeight = true;
    f.verticalAlign = Middle;
    f.horizontalAlign = Middle;
    f.layout = Vertical;

    var txt = new Text(Util.yadaEvent());
    txt.maxWidth = 800;
    txt.text = "Gamedesign, story: Shess\nArt: ZeusDex\nMusic, SFX: Theodote\nCode: Yanrishatum";
    txt.setPosition(10, 10);
    var drop = new ScaleGrid(Res.textures.ui.tile_backdrop_31x.toTile(), 31, 31, f);
    drop.width = txt.textWidth + 20;
    drop.height = txt.textHeight + 20;
    drop.addChild(txt);
    
    f.visible = false;
    credits = f;
  }
  
  function campClick(e:Event)
  {
    State.camp();
  }
  
  public function step()
  {
    camp.visible = State.instruments >= Math.ceil(State.humans * State.config.camp_cost);
    var max = State.maxCarry();
    people.text = "PEOPLE: " + State.humans;
    food.text = "FOOD: " + State.food + "<br/><font face='ui'>MAX: " + max + "</font>";
    water.text = "WATER: " + State.water + "<br/><font face='ui'>MAX: " + max + "</font>";
    clothing.text = "CLOTHES: " + State.clothing + "<br/><font face='ui'>MAX: " + max + "</font>";
    instruments.text = "TOOLS: " + State.instruments + "<br/><font face='ui'>MAX: " + max + "</font>";
  }
  
  
}

class UIMenu extends Object
{
  
  var music:SimpleButton;
  var sfx:SimpleButton;
  var menu:SimpleButton;
  
  public function new(?parent)
  {
    super(parent);
    var f = new Flow(this);
    f.layout = Vertical;
    f.horizontalAlign = Middle;
    var sep = Res.textures.ui.button_separator.toTile();
    music = Util.button("MUSIC: ON", Res.textures.ui.button_idle, Res.textures.ui.button_over, Res.textures.ui.button_press, null, f);
    music.onClick = function(_) {
      var isOn = SoundSystem.music.volume == 1;
      var txt:Text = music.find((o) -> Std.downcast(o, Text));
      if (isOn)
      {
        SoundSystem.music.volume = 0;
        txt.text = "MUSIC: OFF";
      }
      else 
      {
        SoundSystem.music.volume = 1;
        txt.text = "MUSIC: ON";
      }
    }
    new Bitmap(sep, f);
    sfx = Util.button("SFX: ON", Res.textures.ui.button_idle, Res.textures.ui.button_over, Res.textures.ui.button_press, null, f);
    sfx.onClick = function(_) {
      var isOn = SoundSystem.sfx.volume == 1;
      var txt:Text = sfx.find((o) -> Std.downcast(o, Text));
      if (isOn)
      {
        SoundSystem.sfx.volume = 0;
        txt.text = "SFX: OFF";
      }
      else 
      {
        SoundSystem.sfx.volume = 1;
        txt.text = "SFX: ON";
      }
    }
    new Bitmap(sep, f);
    menu = Util.button("CREDITS", Res.textures.ui.button_idle, Res.textures.ui.button_over, Res.textures.ui.button_press, null, f);
    menu.onClick = function(_) {
      State.ui.credits.visible = !State.ui.credits.visible;
    }
    new Bitmap(sep, f);
  }
  
}