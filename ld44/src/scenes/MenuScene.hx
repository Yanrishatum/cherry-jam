package scenes;

import h2d.HtmlText;
import h2d.Text;
import h2d.Object;
import h2d.Tile;
import h2d.RenderContext;
import hxd.Event;
import h2d.Interactive;
import hxd.Res;
import h2d.Bitmap;
import h2d.Scene;

class MenuScene extends Scene {
  
  var charSelect:Interactive;
  var charlist = [CarsKind.emo, CarsKind.stroker, CarsKind.rider, CarsKind.booty];
  var txt:HtmlText;
  var warning:Text;
  
  public function new()
  {
    super();
    setFixedSize(1920, 1080);
    defaultSmooth = true;
    new Bitmap(Res.ui.bgmenu.toTile(), this);
    
    new SBtn(0, this).onClick = start;
    new SBtn(1, this).onClick = idiots;
    new SBtn(2, this).onClick = settings;
    new SBtn(3, this).onClick = authors;
    
    warning = new Text(Res.ui.elmessiri.toFont(), this);
    warning.visible = false;
    warning.textAlign = Center;
    warning.x = 1920 / 2;
    warning.y = 1080 / 2 + 40;
    warning.textColor = 0xffff0000;
    warning.text = "Programmer was too dead inside\nto add even those simple screens.\nAs well as fix some critical bugs.";
    warning.dropShadow = { dx: 2, dy: 2, color: 0, alpha: 1 };
    warning.scale(2);
    warning.rotation = Math.PI * -.1;
    
    charSelect = new Interactive(1920, 1080, this);
    charSelect.cursor = Default;
    charSelect.visible = false;
    new Bitmap(Res.ui.charselect.toTile(), charSelect);
    var faces = Res.ui.faces.toTile().gridFlatten(154);
    var xx = [387, 387 + 326, 387 + 326 * 2, 1375];
    for (i in 0...4)
    {
      var b:Interactive = new Interactive(154, 154, charSelect);
      b.setPosition(xx[i], 264);
      new Bitmap(faces[i], b);
      new Bitmap(faces[i + 4], b).visible = false;
      b.onPush = showAngery.bind(b);
      b.onRelease = hideAngery.bind(b);
      b.onOver = showInfo.bind(i);
      b.onClick = selectChar.bind(i);
    }
    txt = new HtmlText(Res.ui.elmessiri.toFont(), charSelect);
    txt.setPosition(358+100, 542+20);
    txt.maxWidth = 1000;
  }
  
  function showAngery(i:Interactive, e:Event)
  {
    i.children[1].visible = true;
  }
  
  function hideAngery(i:Interactive, e:Event)
  {
    i.children[1].visible = false;
  }
  
  function showInfo(i:Int, e:Event)
  {
    var i = Data.cars.get( charlist[i] ).character;
    txt.text = i.tech + "<br/><br/>" + i.fluff;
  }
  
  function selectChar(i:Int, e:Event)
  {
    LD.char = Data.cars.get(charlist[i]);
    Main.inst.setScene(new MerchantScene());
  }
  
  function start(e:Event)
  {
    // Main.inst.setScene(new MerchantScene());
    charSelect.visible = true;
    // Main.inst.setMap("test.tmx", 1);
  }
  
  function authors(e:Event)
  {
    warning.visible = true;
  }
  
  function idiots(e:Event)
  {
    warning.visible = true;
  }
  function settings(e:Event)
  {
    warning.visible = true;
  }
}

class SBtn extends Interactive
{
  
  var over:Bool;
  var t:Tile;
  
  public function new(index:Int, p:Object)
  {
    super(638, 146, p);
    setPosition(662, 314 + 167 * index);
    t = Tile.fromColor(0xffffff, 638, 146, 0.14);
  }
  
  override public function onOver(e:Event)
  {
    over = true;
  }
  override public function onOut(e:Event)
  {
    over = false;
  }
  
  override private function draw(ctx:RenderContext)
  {
    if (over) emitTile(ctx, t);
    super.draw(ctx);
  }
  
}