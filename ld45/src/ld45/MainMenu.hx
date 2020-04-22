package ld45;

import h2d.Bitmap;
import hxd.Res;
import h2d.Flow;
import h2d.Object;

class MainMenu extends Object {
  
  public function new (?parent)
  {
    super(parent);
    var f = new Flow(this);
    f.maxWidth = 1280;
    f.maxHeight = 720;
    f.fillWidth = true;
    f.fillHeight = true;
    f.verticalAlign = Middle;
    f.horizontalAlign = Middle;
    f.layout = Vertical;
    
    var sep = Res.textures.ui.button_separator.toTile();
    
    new Bitmap(Res.textures.ui.bar_name.toTile(), f);
    new Bitmap(sep, f);
    Util.button("Start", Res.textures.ui.button_idle, Res.textures.ui.button_over, Res.textures.ui.button_press, null, f);
    new Bitmap(sep, f);
    Util.button("", Res.textures.ui.button_idle, Res.textures.ui.button_over, Res.textures.ui.button_press, null, f);
    
  }
  
  
  
}