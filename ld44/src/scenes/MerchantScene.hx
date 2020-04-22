package scenes;

import h2d.Object;
import h2d.HtmlText;
import h2d.Text;
import hxd.Event;
import h2d.Interactive;
import h2d.ui.Button;
import hxd.Res;
import h2d.Bitmap;
import h2d.Scene;

class MerchantScene extends Scene {
  
  var txt:HtmlText;
  var itemList:Array<Skills>;
  var selected:Array<Skills>;
  
  public function new() {
    
    super();
    
    defaultSmooth = true;
    setFixedSize(1920, 1080);
    new Bitmap(Res.ui.screen_merchant.toTile(), this);
    
    var items = Data.skills.all.filter( (s) -> !s.is_ability && s.id != jolly_hammer );
    while (items.length > 6)
    {
      items.splice(Std.int(Math.random() * items.length), 1);
    }
    itemList = new Array();
    selected = new Array();
    
    var x = 0;
    var y = 0;
    var coords = [[[660,448], [815,448], [975,448]], [[660,638], [815,638], [975,638]]];
    var coords2 = [[[625,516], [776,516], [937,516]], [[625,706], [776,706], [937,706]]];
    for (i in items)
    {
      var tile = Res.load(i.icon).toTile().center();
      var btm:Bitmap = new Bitmap(tile, this);
      btm.setPosition(coords[y][x][0], coords[y][x][1]);
      var int = new Interactive(114, 114, this);
      int.setPosition(coords[y][x][0] - 62, coords[y][x][1] - 62);
      int.onOver = showItem.bind(i);
      int.onClick = buy.bind(_, btm, i);
      var txt = new Text(Res.ui.elmessiri.toFont(), this);
      txt.setPosition(coords2[y][x][0], coords2[y][x][1] - 5);
      txt.text = (i.price * 100) + "%";
      txt.textColor = 0xffffe9d2;
      itemList.push(i);
      if (++x == 3) { x = 0; y++; }
    }
    
    txt = new HtmlText(Res.ui.elmessiri.toFont(), this);
    txt.maxWidth = 380;
    txt.textColor = 0xffffe9d2;
    txt.setPosition(520, 46);
    
    var b = new Button(100, 30, "Start", this);
    b.setScale(2);
    b.setPosition(1920 - 250, 1080 - 80);
    b.onClick = start;
  }
  
  function start(e:Event)
  {
    var sss = Data.skills.all.filter( (s) -> !s.is_ability && s.id != jolly_hammer );
    while (selected.length < 2)
    {
      selected.push(sss[Std.int(Math.random() * sss.length)]);
      sss.remove(selected[selected.length - 1]);
    }
    LD.sel = selected;
    var r = LD.roster[Std.int(LD.roster.length * Math.random())];
    Main.inst.setMap(r.map, r.layer);
  }
  
  function showItem(i:Skills, e:Event)
  {
    txt.text = "<font color='#f7b46f'>" + i.name + "</font><br/>" + i.tech + "<br/><br/>" + i.fluff;
  }
  
  function buy(e:Event, int:Bitmap, i:Skills)
  {
    if (selected.remove(i))
    {
      int.alpha = 1;
    }
    else if (selected.length < 2)
    {
      selected.push(i);
      int.alpha = 0.4;
    }
  }
  
}