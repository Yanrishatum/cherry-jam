import h2d.Font;
import h2d.Bitmap;
import h2d.ui.SimpleButton;
import h2d.ui.AdvancedButton;
import h2d.Tile;
import h2d.ui.EventInteractive;
import hxd.res.Image;
import hxd.Res;
import hxd.res.DefaultFont;
import h2d.Text;
import hxd.res.Model;
import h3d.shader.Outline;
import ld45.Const;
import h3d.scene.Object;

class Util {
  
  public static function button(text:String, idle:Image, hover:Image, press:Image, ?disabled:Image, ?parent:h2d.Object)
  {
    var t = idle.toTile();
    var btn = new SimpleButton(t.iwidth, t.iheight, new Bitmap(t), new Bitmap(hover.toTile()), new Bitmap(press.toTile()), disabled != null ? new Bitmap(disabled.toTile()) : null, parent);
    var l = new Text(Util.yadaSmol());
    btn.onClickEvent.add( (_) -> ld45.SoundSystem.play(Res.sfx.ld_sfx_knopka));
    l.text = text;
    l.textAlign = Center;
    l.maxWidth = t.width;
    l.dropShadow = { dx: 1, dy: 1, color: 0, alpha: 0.5 };
    l.y = (t.height - l.textHeight) / 2;
    btn.addChild(l);
    return btn;
  }
  
  public static inline function yadaUi():Font
  {
    return Res.textures.font.yadatada_ui.toFont();
  }
  
  public static inline function yadaSmol():Font
  {
    return Res.textures.font.yadatada_ui.toFont();
  }
  
  public static inline function yadaEvent():Font
  {
    return Res.textures.font.yada_event.toFont();
  }
  
  public static function addOutline(to:Object)
  {
    var cont = new Object(to.parent);
    cont.addChild(to);
    var c = to.clone();
    
    for (m in to.getMaterials())
    {
      var ap = m.allocPass("outline");
      ap.culling = Front;
      // var outline = Main.cache.loadModel(Res.models.char);
      // outline.scale(1.1);
      var out = new Outline();
      out.size = 0.1;
      out.color.setColor(0xff221111);
      ap.addShader(out);
    }
  }
  
  public static function addModelOutline(to:Object, model:Model)
  {
    var m = Main.cache.loadModel(model);
    to.addChild(m);
  }
  
  public static function loadOutlined(base:Model, outline:Model)
  {
    var o = new Object();
    o.addChild(Main.cache.loadModel(base));
    o.addChild(Main.cache.loadModel(outline));
    return o;
  }
  
}

enum abstract HexDirection(Int) to Int
{
  var Right = 0;
  var BottomRight = 1;
  var BottomLeft = 2;
  var Left = 3;
  var TopLeft = 4;
  var TopRight = 5;
  
  
}

class HexCoord
{
  
  static final ANGLES:Array<Float> = [
    0, hxd.Math.degToRad(60), hxd.Math.degToRad(120),
    Math.PI, hxd.Math.degToRad(240), hxd.Math.degToRad(320)
  ];
  
  public var q:Int; // x
  public var r:Int; // z
  public var s:Int; // y
  public var x(get, never):Int;
  public var y(get, never):Int;
  public var cx(get, never):Int;
  public var cy(get, never):Int;
  
  inline function get_x()
  {
    return q + ((r - (r&1)) >> 1);
  }
  inline function get_y()
  {
    return r;
  }
  
  inline function get_cx() return Math.floor(get_x() / Const.MAP_W);
  inline function get_cy() return Math.floor(get_y() / Const.MAP_H);
  
  public function new(q:Int = 0, r:Int = 0, s:Int = 0)
  {
    this.q = q;
    this.r = r;
    this.s = s;
  }
  
  public function setOffset(x:Int, y:Int)
  {
    q = x - ((y - (y & 1)) >> 1);
    r = y;
    s = -q-r;
  }
  
  public function set(q:Int, r:Int, s:Int)
  {
    this.q = q;
    this.r = r;
    this.s = s;
  }
  
  public function calcPosition(target:Object, ox:Float, oy:Float)
  {
    // var x = this.cx 
    target.x = inline screenX() + ox;
    target.y = inline screenY() + oy;
    
  }
  
  public function screenX():Float return Const.HEX_WIDTH * q + Const.HEX_HW * r;
  public function screenY():Float return Const.HEX_V_STEP * r;
  
  public function add(other:HexCoord):HexCoord
  {
    return new HexCoord(this.q + other.q, this.r + other.r, this.s + other.s);
  }
  
  public function addSelf(q:Int, r:Int, s:Int):HexCoord
  {
    this.q += q;
    this.r += r;
    this.s += s;
    return this;
  }
  
  public function sub(other:HexCoord):HexCoord
  {
    return new HexCoord(this.q - other.q, this.r - other.r, this.s - other.s);
  }
  
  static final DIR_TABLE:Array<Array<HexDirection>> = [
    [Right, Right, TopRight], // q = -1
    [BottomRight, TopLeft, TopLeft],
    [BottomLeft, Left, Left], // q = 1
  ];
  public function direction():HexDirection
  {
    // TODO: Safety?
    return DIR_TABLE[q + 1][r + 1];
  }
  
  public function angle():Float
  {
    return ANGLES[direction()];
  }
  
  public function length():Int
  {
    return (hxd.Math.iabs(q) + hxd.Math.iabs(r) + hxd.Math.iabs(s)) >> 1;
  }
  
  public function distance(other:HexCoord)
  {
    return ((hxd.Math.iabs(this.q - other.q) + hxd.Math.iabs(this.r - other.r) + hxd.Math.iabs(this.s - other.s)) >> 1);
  }
  
  public function equals(other:HexCoord)
  {
    return this.q == other.q && this.r == other.r && this.s == other.s;
  }
  
  public function isNeighbor(other:HexCoord)
  {
    return (inline distance(other)) == 1;
  }
  
}