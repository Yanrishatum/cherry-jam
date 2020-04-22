package ld45;

import h2d.Flow;
import hxd.Res;
import h2d.ScaleGrid;
import ld45.State;
import hxd.res.DefaultFont;
import h2d.HtmlText;
import h2d.Text;
import h2d.ObjectFollower;

class TileInfo extends ObjectFollower {
  
  var backdrop:ScaleGrid;
  var info:HtmlText;
  
  public function new(parent)
  {
    super(null, parent);
    backdrop = new ScaleGrid(Res.textures.ui.tile_backdrop_31x.toTile(), 31, 31, this);
    info = new HtmlText(Util.yadaSmol(), this);
    info.setPosition(10,10);
    info.dropShadow = { dx: 1, dy: 1, color: 0, alpha: 0.5 };
    visible = true;
  }
  
  public function showText(text:String, obj)
  {
    visible = true;
    follow = obj;
    setText(text);
  }
  
  public function showTextAt(text:String, x:Float, y:Float, align:FlowAlign = Left, valign:FlowAlign = Top)
  {
    visible = true;
    follow = null;
    // this.x = x;
    // this.y = y;
    setText(text);
    switch (align)
    {
      case Left: this.x = x;
      case Right: this.x = x - backdrop.width;
      default:
    }
    switch(valign)
    {
      case Top: this.y = y;
      case Bottom: this.y = y - backdrop.height;
      default:
    }
  }
  
  public function show(tile:HexTile)
  {
    visible = true;
    follow = tile;
    var d:TileBalance = Reflect.field(State.config.tiles, tile.type.getName());
    var str = new StringBuf();
    var had = false;
    inline function add(label:String, cur:Int, consume:Int)
    {
      if (had) str.add(", ");
      had = true;
      var sign = consume < 0 ? "+" : "-";
      consume = hxd.Math.iabs(consume);
      str.add('<font color="${cur < consume ? "#ff2233" : "#ffffff"}">$sign$consume $label</font>');
    }
    if (d.foodPerPerson != 0 || d.waterPerPerson != 0 || d.clothingPerPerson != 0)
    {
      str.add("<p>Travel: ");
      if (d.foodPerPerson != 0) add("food", State.food, d.foodPerPerson * State.humans);
      if (d.waterPerPerson != 0) add("water", State.water, d.waterPerPerson * State.humans);
      if (d.clothingPerPerson != 0) add("clothes", State.clothing, d.clothingPerPerson * State.humans);
      if (tile.quest != -1) {
        str.add('. <font color="#22ff33">Event!</font>');
      }
      str.add("</p>");
    }
    else if (tile.quest != -1 && (tile.resource == -1 || d.gather.length == 0))
    {
      if (tile.isWalkable()) str.add("<p>Travel: ");
      else str.add("<p>Camp nearby: ");
      str.add('<font color="#22ff33">Event!</font></p>');
    }
    if (tile.resource != -1 && d.gather.length > 0)
    {
      if (tile.isWalkable()) str.add("<p>Gather: ");
      else str.add("<p>Camp nearby: ");
      had = false;
      final names = [ "food" => "food", "water" => "water", "clothing" => "clothes", "instruments" => "tools"];
      for (r in d.gather)
      {
        add(names[r[0]], 99999, State.gainAmount(-(r[1]:Int)));
      }
      if (!tile.isWalkable() && tile.quest != -1) {
        str.add('. <font color="#22ff33">Event!</font>');
      }
      str.add("</p>");
    }
    
    // if (d.instruments != null)
    // {
    //   str.add('<p>Can spend ${d.instruments.use} tools to create a ${d.instruments.convert.toLowerCase()}.</p>');
    // }
    str.add('<p>${d.descr}</p>');
    #if debug
    // str.add('<p>DEBUG: Edge: [${tile.pos.x},${tile.pos.y}] ${tile.edge} </p>');
    #end
    setText(str.toString());
  }
  
  inline function setText(str:String)
  {
    info.text = str;
    backdrop.width = info.textWidth + 20;
    var off = StringTools.endsWith(str, "</p>") ? 10 : 20;
    backdrop.height = info.textHeight + off;
  }
  
  public function hide()
  {
    follow = null;
    visible = false;
  }
  
}