package game;

import h3d.Vector;
import hxd.Timer;
import h2d.Tile;
import h2d.Text;
import engine.HXP;
import hxd.Event;
import h2d.Bitmap;
import h2d.Flow;
import game.comps.GameUI;
import gasm.heaps.components.HeapsSpriteComponent;
import hxd.Res;
import h2d.Object as Sprite;
import hxd.Key;
import engine.Music;
import engine.HScene;

class MenuScene extends HScene
{
  
  private var music:Bool;
  private var s:Sprite;
  
  private var key:h2d.Bitmap;
  private var primary:Sprite;
  private var loading:h2d.Bitmap;
  
  override public function setup()
  {
    var bg = Res.menubackground.toTile();
    
    s = new Sprite();
    new h2d.Bitmap(bg, s);
    owner.add(new HeapsSpriteComponent(s));
    
    var uis = Res.menu_ui.getSize();
    
    var bg2 = new Bitmap(Res.menu_ui.toTile(), s);
    primary = bg2;
    bg2.x = (1280 - uis.width) / 2;
    bg2.y = (720 - uis.height) / 2;
    var f:Flow = new Flow(bg2);
    f.horizontalAlign = FlowAlign.Middle;
    f.verticalAlign = FlowAlign.Middle;
    f.layout = Vertical;
    f.minWidth = uis.width;
    f.minHeight = uis.height;
    new TextButton("New game", null, 308, f).onClick = ng;
    new TextButton("Settings", null, 308, f).onClick = st;
    // new TextButton("Help", null, 308, f).onClick = hp;
    bg2.visible = false;
    
    var tile:Tile = Res.menu_click_to_open.toTile();
    key = new h2d.Bitmap(tile, s);
    key.x = (1280 - tile.width) / 2;
    key.y = (720 - tile.height) / 2;
    key.colorAdd = new Vector(0, 0, 0, 0);
    
    tile = Res.loading.toTile();
    loading = new h2d.Bitmap(tile, s);
    loading.x = (1280 - tile.width) / 2;
    loading.y = (720 - tile.height) / 2;
    loading.visible = false;
  }
  
  private function ng(e:Event):Void
  {
    GameUI.click();
    primary.visible = false;
  }
  
  private function st(e:Event):Void
  {
    new game.comps.SettingsWindow(s);
    GameUI.click();
  }
  
  private function hp(_):Void
  {
    // new game.comps.HelpWindow(s);
    GameUI.click();
  }
  
  override public function update(delta:Float)
  {
    if (!music)
    {
      if (Key.isReleased(Key.MOUSE_LEFT))
      {
        music = true;
        #if js
        Music.play("menu_thing.mp3");
        #else 
        Music.play(Res.sfx.music.menu_thing);
        #end
        primary.visible = true;
        key.visible = false;
      }
      var pulse:Float = Math.sin(Timer.lastTimeStamp * 2) * .1 + .05;
      key.colorAdd.set(pulse, pulse, pulse, 0);
      
    }
    else if (!primary.visible)
    {
      if (loading.visible)
      {
        HXP.engine.scene = new BattleScene();
      }
      loading.visible = true;
    }
  }
  
}