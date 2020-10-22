package ldx;

import h2d.col.Point;
import hxd.Event;
import h2d.Interactive;
import hxd.Timer;
import h2d.RenderContext;
import h2d.Tile;
import h2d.SpriteBatch;
import h2d.Bitmap;
import h2d.Object;

class RedRay extends Object {
  
  var pivot:Object;
  var manta:Bitmap;
  var eyes:Bitmap;
  var mouth:Bitmap;
  var mouthEmotes:Array<Tile>;
  var gun:Bitmap;
  var text:Bitmap;
  var gunX:Float;
  var gunY:Float;
  
  var pointTo:Point;
  
  static inline var BOUNDS_EXPAND = 3;
  
  static var tileset:Tile;
  static inline function checkTileset() {
    if (tileset == null) tileset = hxd.res.Embed.getResource("ldx/logo.png").toTile();
  }
  
  public static function getGun(dx:Float = 0, dy:Float = 0):Tile {
    checkTileset();
    return tileset.sub(193, 76, 81, 62, dx, dy);
  }
  
  public function new(withName:Bool = true, withGun:Bool = true, ?parent) {
    super(parent);
    pivot = new Object(this);
    pivot.setPosition(-111, -114);
    
    checkTileset();
    manta = new Bitmap(tileset.sub(0, 76, 192, 167), pivot);
    manta.smooth = true;
    
    eyes = new Bitmap(tileset.sub(193, 139, 80, 26, 47, 21), manta);
    eyes.smooth = true;
    mouthEmotes = [
      tileset.sub(210, 166, 18, 11, 81, 35),
      tileset.sub(193, 166, 16, 18, 84, 35)
    ];
    mouth = new Bitmap(mouthEmotes[0], manta);
    mouth.smooth = true;
    
    gun = new Bitmap(tileset.sub(193, 76, 81, 62, -29, -27), pivot);
    gun.smooth = true;
    gun.setPosition(gunX = 164 + 29, gunY = 78 + 27);
    gun.visible = withGun;
    
    text = new Bitmap(tileset.sub(0, 0, 213, 75), pivot);
    text.smooth = true;
    // text.setPosition(4, 177);
    text.setPosition(8, 177);
    text.visible = withName;
    
    var inter = new Interactive(manta.tile.iwidth, manta.tile.iheight, manta);
    inter.onOver = emoteSwitch.bind(1);
    inter.onOut = emoteSwitch.bind(0);
    inter.onClick = bonk;
  }
  
  function bonk(e:Event) {
    clickVelocity = 300;
  }
  
  function emoteSwitch(index:Int, e:Event) {
    mouth.tile = mouthEmotes[index];
  }
  
  public function redden() {
    manta.color.setColor(0xffa43e33);
  }
  
  public function center() {
    var bnd = getSize();
    pivot.x = -bnd.width / 2;
    pivot.y = -bnd.height / 2;
  }
  
  public function fitInto(width:Float, height:Float) {
    var bnd = getSize();
    bnd.xMin -= BOUNDS_EXPAND;
    bnd.xMax += BOUNDS_EXPAND;
    bnd.yMin -= BOUNDS_EXPAND;
    bnd.yMax += BOUNDS_EXPAND;
    // pivot.x = BOUNDS_EXPAND;
    // pivot.y = BOUNDS_EXPAND;
    this.scale(Math.min(width / bnd.width, height / bnd.height));
    // 245x252
  }
  
  public function pointAt(x:Float, y:Float) {
    pointTo = new Point(x, y);
  }
  
  var blinkTimer:Float = 0;
  var nextBlink:Float = Math.random();
  static inline var CLOSED_TIME = 0.2;
  
  // var mouthTimer:Float = Math.random() * 6 + 4;
  var clickVelocity:Float = 0;
  var clickOffset:Float = 0;
  
  override function sync(ctx:RenderContext)
  {
    super.sync(ctx);
    blinkTimer += ctx.elapsedTime;
    if (eyes.visible) {
      if (blinkTimer > nextBlink) {
        blinkTimer -= nextBlink;
        eyes.visible = false;
        if (Math.random() > 0.8) nextBlink = CLOSED_TIME * 3;
        else nextBlink = Math.random() * 5 + 1;
      }
    } else if(blinkTimer >= CLOSED_TIME) eyes.visible = true;
    
    // mouthTimer -= ctx.elapsedTime;
    // if (mouthTimer < 0) {
    //   mouthTimer = Math.random() * 6 + 4;
    //   mouth.tile = mouthEmotes[dn.M.rand(mouthEmotes.length)];
    // }
    if (clickVelocity > 0) {
      clickOffset += clickVelocity * ctx.elapsedTime;
      clickVelocity -= Math.max(700, clickOffset * 100) * ctx.elapsedTime;
    } else {
      clickOffset = hxd.Math.lerp(clickOffset, 0, ctx.elapsedTime * 4);
    }
    
    manta.y = clickOffset + Math.sin(Timer.lastTimeStamp * 2.4) * 7;
    manta.x = Math.cos(Timer.lastTimeStamp * 1.2) * 10;
    gun.y = hxd.Math.lerp(gun.y, gunY + manta.y, ctx.elapsedTime * 4);
    gun.x = hxd.Math.lerp(gun.x, gunX + manta.x, ctx.elapsedTime * 4);
    if (pointTo != null) {
      var pt = new Point(pointTo.x, pointTo.y);
      globalToLocal(pt);
      var rotTarget = Math.atan2(pt.y - gun.y, pt.x - gun.x);
      gun.rotation = hxd.Math.lerp(gun.rotation, rotTarget, ctx.elapsedTime * 2);
    } else {
      gun.rotation = Math.cos(Timer.lastTimeStamp * .5 + 0.2) * 0.2;
    }
  }
  
}