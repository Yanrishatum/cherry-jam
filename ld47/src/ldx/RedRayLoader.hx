package ldx;

import h2d.col.Bounds;
import hxd.Res;
import ch2.ui.CustomButton;
import h2d.Interactive;
import hxd.Timer;
import h2d.SpriteBatch;
import h2d.Text;
import h2d.Tile;
import h2d.Bitmap;
import h2d.RenderContext;
import h2d.Graphics;
import cherry.res.ManifestLoader;
import h2d.Object;

class RedRayLoader extends Object {
  
  var loader:ManifestLoader;
  var onLoaded:Void->Void;
  var w:Int;
  var h:Int;
  var cx:Int;
  var cy:Int;
  
  var bg:Bitmap;
  
  var pivot:Object;
  
  var primary:CircleShader;
  var secondary:Array<CircleShader>;
  var secondaryTrails:Array<CircleShader>;
  var logoBG1:CircleShader;
  var logoBG2:CircleShader;
  
  var logo:RedRay;
  var fileText:Text;
  
  var bubbles:SpriteBatch;
  static inline var BUBBLE_COUNT = 15;
  
  var loaded:Bool = false;
  var disperce:DisperceShader;
  
  public function new(loader:ManifestLoader, onLoaded:Void->Void, ?parent:Object) {
    super();
    ManifestLoader.concurrentFiles = 6;
    Utils.bgColor(BG_COLOR);
    // bg = new Bitmap(h2d.Tile.fromColor(0xffffff), this);
    // bg.color.setColor(0xff000000 | BG_COLOR);
    
    bubbles = new h2d.SpriteBatch(h2d.Tile.fromColor(0x443832), this);
    bubbles.hasRotationScale = true;
    bubbles.hasUpdate = true;
    var s = new CircleShader();
    s.isHollow = true;
    bubbles.addShader(s);
    
    pivot = new Object(this);
    
    var size, btm;
    
    secondaryTrails = [for (i in 0...ManifestLoader.concurrentFiles) {
      size = (INSET_RADIUS + i * SECONDARY_SIZE + SECONDARY_SIZE - SECONDARY_SPACING) * 2;
      btm = new Bitmap(Tile.fromColor(SECONDARY_COLOR, size, size), pivot);
      btm.tile.setCenterRatio();
      var s = new CircleShader();
      s.isPie = true;
      s.pieStart = TOP;
      s.pieLength = 0;
      s.isHollow = true;
      s.width = ((SECONDARY_SIZE - SECONDARY_SPACING) * 2) / size;
      btm.addShader(s);
      s;
    }];
    
    size = (INSET_RADIUS + PRIMARY_SIZE) * 2;
    btm = new Bitmap(Tile.fromColor(MAIN_COLOR, size, size), pivot);
    btm.tile.setCenterRatio();
    primary = new CircleShader();
    primary.isPie = true;
    primary.pieStart = TOP;
    primary.pieLength = 0;
    btm.addShader(primary);
    
    secondary = [for (i in 0...ManifestLoader.concurrentFiles) {
      size = (INSET_RADIUS + i * SECONDARY_SIZE + SECONDARY_SIZE - SECONDARY_SPACING) * 2;
      btm = new Bitmap(Tile.fromColor(SECONDARY_COLOR, size, size), pivot);
      btm.tile.setCenterRatio();
      var s = new CircleShader();
      s.isPie = true;
      s.pieStart = TOP;
      s.pieLength = 0;
      s.isHollow = true;
      s.width = ((SECONDARY_SIZE - SECONDARY_SPACING) * 2) / size;
      btm.addShader(s);
      s;
    }];
    
    size = INSET_RADIUS * 2;
    btm = new Bitmap(Tile.fromColor(INSET_COLOR, size, size), pivot);
    btm.tile.setCenterRatio();
    btm.addShader(logoBG1 = new CircleShader());
    
    size = LOGO_RADIUS * 2;
    btm = new Bitmap(Tile.fromColor(INSET_COLOR2, size, size), pivot);
    btm.tile.setCenterRatio();
    btm.addShader(logoBG1 = new CircleShader());
    
    logo = new RedRay(pivot);
    var size = LOGO_RADIUS * 1.5;
    logo.center();
    logo.fitInto(size, size);
    
    var fnt = hxd.res.DefaultFont.get().clone();
    var max = 0.;
    for (i in '0'.code ... ';'.code) max = hxd.Math.max(fnt.getChar(i).width, max);
    fnt.getChar(' '.code).width = max;
    for (i in '0'.code ... ';'.code) fnt.getChar(i).width = max;
    
    fileText = new Text(fnt, this);
    fileText.x = 3;
    fileText.textColor = INSET_COLOR;
    
    this.onLoaded = onLoaded;
    this.loader = loader;
    loader.onFileLoadStarted = fileStart;
    loader.onFileLoaded = makeTrail;
    loader.onFileProgress = progressUpdate;
    loader.onLoaded = finished;
    
    loader.loadManifestFiles();
    // TODO: Buttons - continue with/without sound
    // TODO: File text
    // TODO: Minimal logo movements.
  }
  
  function finished() {
    Main.initAssets();
    haxe.Timer.delay(function() {
      loaded = true;
      
      var icons = Res.ldx.volume_icons.toTile();
      var sound = new BubbleButton(cy, icons.sub(0, 0, 86, 74).center(), "Play with sound", begin.bind(false), this);
      var noSound = new BubbleButton(cy, icons.sub(86, 0, 86, 74).center(), "Play without sound", begin.bind(true), this);
      sound.x = Math.round(cx + cx / 3);
      noSound.x = Math.round(w - cx / 3);
    }, 1000);
  }
  
  function begin(mute:Bool) {
    if (disperce != null) return;
    R.music.mute = mute;
    R.sfx.mute = mute;
    // remove();
    var s = disperce = new DisperceShader();
    s.bg.setColor(BG_COLOR);
    this.filter = new DisperceFilter(s, 1.5);
    
    this.onLoaded();
  }
  
  override function onAdd()
  {
    var s = getScene();
    w = s.width;
    h = s.height;
    cx = w >> 1;
    cy = h >> 1;
    // bg.width = w;
    // bg.height = h;
    
    var t = bubbles.tile;
    for (i in 0...BUBBLE_COUNT)
      bubbles.add(new Bubbles(t, Math.random() * (w + 300) - 300, Math.random() * h, h, w + 300, -300));
    
    pivot.setPosition(cx, cy);
    // var test = new h2d.Bitmap(h2d.Tile.fromColor(MAIN_COLOR, (INSET_RADIUS + Std.int(PRIMARY_SIZE))*2, (INSET_RADIUS + Std.int(PRIMARY_SIZE))*2), this);
    // var circ = new CircleShader();
    // circ.isHollow = true;
    // circ.isPie = true;
    // circ.width = PRIMARY_SIZE * 2 / test.tile.width;
    // circ.pieStart = -Math.PI * .45;
    // circ.pieLength = Math.PI * .6;
    // test.addShader(circ);
    
    super.onAdd();
  }
  
  static inline var BG_COLOR = 0x282828;
  static inline var MAIN_COLOR = 0xa43e33;
  static inline var SECONDARY_COLOR = 0x6F635D;
  static inline var INSET_COLOR = 0xE3E3E3;
  static inline var INSET_COLOR2 = 0x4B423D;
  // static inline var INSET_COLOR2 = 0x84CB3E;
  
  static var INSET_RADIUS = 175; //100;
  static var LOGO_RADIUS = 122; //100;
  static var SECONDARY_SPACING = 2;
  static var SECONDARY_SIZE = 6;
  static var PRIMARY_SIZE = 86;//SECONDARY_SPACE * 2.25;
  
  static inline var TOP = hxd.Math.PI * -.5;
  
  var smoothTotal:Float = 0;
  
  function makeTrail(task:LoaderTask) {
    secondary[task.slot].pieLength = (1 - smoothTotal) * Math.PI * 2;
    var shader = secondaryTrails[task.slot];
    shader.pieLength = -(1 - smoothTotal) * Math.PI * 2;
  }
  
  function progressUpdate(task:LoaderTask) {
    // secondary[task.slot].pieLength = hxd.Math.lerp(secondary[task.slot].pieLength, (task.loaded / task.total) * (1 - smoothTotal) * Math.PI * 2, 0.1);
  }
  
  function fileStart(task:LoaderTask) {
    secondary[task.slot].pieLength = 0;
  }
  
  static var tmpBounds = new Bounds();
  override function clipBounds(ctx:RenderContext, bounds:Bounds)
  {
    tmpBounds.set(0, 0, w, h);
    // bounds.doIntersect(tmpBounds);
    bounds.load(tmpBounds);
    super.clipBounds(ctx, bounds);
  }
  
  override function sync(ctx:RenderContext) {
    super.sync(ctx);
    
    if (loaded) {
      pivot.x = hxd.Math.lerp(pivot.x, cx - INSET_RADIUS - PRIMARY_SIZE, ctx.elapsedTime * 2);
      if (disperce != null) {
        if (disperce.time > disperce.duration) {
          remove();
        }
      }
    }
    
    final total = loader.loadedFiles / loader.totalFiles;
    smoothTotal = hxd.Math.lerp(smoothTotal, total, 0.1);
    primary.pieLength = smoothTotal * Math.PI * -2;
    
    final limit = (1 - smoothTotal) * Math.PI * 2;
    if (loader.tasks != null) {
      for (task in loader.tasks) {
        if (!task.busy) {
          if (secondary[task.slot].pieLength > limit) secondary[task.slot].pieLength = limit;
          else secondary[task.slot].pieLength = hxd.Math.lerp(secondary[task.slot].pieLength, limit, 0.1);
        }
        else
          secondary[task.slot].pieLength = hxd.Math.lerp(secondary[task.slot].pieLength, (task.loaded / task.total) * limit, 0.1);
      }
    } else {
      for (s in secondary) {
        s.pieLength = limit;
      }
    }
    for (t in secondaryTrails) {
      t.pieStart = TOP + smoothTotal * Math.PI * -2;
      if (t.pieLength < 0) t.pieLength = hxd.Math.lerp(t.pieLength, 0, 0.15);
    }
  }
  
}

private class BubbleButton extends Object implements IButtonStateView {
  
  // var baseY:Float;
  var sinOffset:Float;
  var desiredScale = 1.;
  var desiredColor:Int = IDLE_COLOR;
  var anchor:Object;
  var circle:Bitmap;
  var icon:Bitmap;
  var blend:Float = 0;
  var text:Text;
  
  static inline var RADIUS = 64;
  static inline var IDLE_COLOR = 0xff4b423d;
  static inline var ACTIVE_COLOR = 0xffa43e33;
  
  public function new(baseY:Float, icon:Tile, label:String, callback:Void->Void, ?parent) {
    super(parent);
    // this.baseY = baseY;
    this.y = baseY;
    this.sinOffset = Math.random() * Math.PI;
    final radius = RADIUS;
    final radius2 = radius * 2;
    
    anchor = new Object(this);
    var btm = circle = new Bitmap(Tile.fromColor(0xffffff, radius2, radius2), anchor);
    btm.tile.setCenterRatio();
    btm.smooth = true;
    var shader = new CircleShader();
    btm.addShader(shader);
    btm = this.icon = new Bitmap(icon, anchor);
    btm.smooth = true;
    icon.dy += 2;
    // btm.setPosition(-radius, -radius);
    alpha = 0;
    
    text = new Text(R.getFont(24), anchor);
    text.y = radius * 1.1;
    text.textAlign = Center;
    text.text = label;
    text.smooth = true;
    
    var i = new ch2.ui.CustomButton(radius2 * 1.2, radius2 * 1.2, anchor, null, [this]);
    // var i = new Interactive(radius2, radius2, this);
    i.setPosition(-radius * 1.2, -radius * 1.2);
    // i.onOver = (e) -> desiredScale = 1.2;
    // i.onOut = (e) -> desiredScale = @:privateAccess i.scene.events.pushList.indexOf(i) != -1 ? 0.9 : 1;
    // i.onPush = (e) -> desiredScale = 0.9;
    // i.onRelease = (e) -> desiredScale = i.isOver() ? 1.2 : 1;
    i.onClick = (e) -> callback();
    i.isEllipse = true;
  }
  
  public function setState(state:ButtonState, flags:ButtonFlags):Void {
    switch (state) {
      case Hold: desiredScale = 1; desiredColor = ACTIVE_COLOR;
      case Hover: desiredScale = 1.2; desiredColor = ACTIVE_COLOR;
      case Idle: desiredScale = 1; desiredColor = IDLE_COLOR;
      case Press: desiredScale = 0.9; desiredColor = ACTIVE_COLOR;
    }
  }
  
  override function sync(ctx:RenderContext)
  {
    anchor.y = (1 - alpha) * 60 + Math.cos(Timer.lastTimeStamp + sinOffset) * 6;
    if (alpha < 1) {
      alpha = hxd.Math.lerp(alpha, 1, ctx.elapsedTime);
      if (alpha > 0.999) alpha = 1;
    }
    circle.scaleX = circle.scaleY = hxd.Math.lerp(circle.scaleY, desiredScale, ctx.elapsedTime);
    if (desiredColor == IDLE_COLOR) {
      blend -= ctx.elapsedTime * 4;
      if (blend < 0) blend = 0;
    } else if (blend < 1) {
      blend += ctx.elapsedTime * 4;
      if (blend > 1) blend = 1;
    }
    text.alpha = blend;
    // text.y = Math.round(baseY - y + (1 - alpha) * 60 + RADIUS * 1.1);
    circle.color.setColor(hxd.Math.colorLerp(IDLE_COLOR, ACTIVE_COLOR, blend));
    
    super.sync(ctx);
  }
  
}

private class Bubbles extends BatchElement {
  
  var velY:Float;
  var velX:Float;
  var bottom:Float;
  var width:Float;
  var widthOff:Float;
  
  static inline function velXRNG() return Math.random() * 50;
  static inline function velYRNG() return Math.random() * -75 - 25;
  static inline function scaleRNG() return Math.random() * 100 + 25;
  static inline function startOffsetRNG() return Math.random() * 50;
  
  public function new(t, x, y, bottom, width, xoff) {
    super(t);
    this.bottom = bottom;
    this.width = width;
    this.widthOff = xoff;
    this.velX = velXRNG();
    this.velY = velYRNG();
    this.x = x;
    this.scale = scaleRNG();
    this.y = y + scaleY + startOffsetRNG();
    // this.r = 0x44 / 0xff;
    // this.g = 0x38 / 0xff;
    // this.b = 0x32 / 0xff;
  }
  
  override function update(et:Float):Bool
  {
    this.y += velY * Timer.elapsedTime;
    this.x += velX * Timer.elapsedTime;
    // return true;
    if (y + scaleY < 0) {
      this.scale = scaleRNG();
      this.y = bottom + scaleY + startOffsetRNG();
      this.x = widthOff + Math.random() * width;
      velX = velXRNG();
      velY = velYRNG();
    }
    return true;
  }
  
}

private class DisperceFilter extends h2d.filter.Shader<DisperceShader> {
  
  public function new(s, dur) {
    super(s);
    s.duration = dur;
    s.time = 0;
    boundsExtend = 140;
  }
  
  override public function draw(ctx:RenderContext, t:Tile):Tile
  {
    shader.time += ctx.elapsedTime;
    return super.draw(ctx, t);
  }
  
}
private class DisperceShader extends h3d.shader.ScreenShader {
  
  static var SRC = {
    @param var texture:Sampler2D;
    @param var time:Float;
    @param var duration:Float;
    @param var bg:Vec3;
    
    function fragment() {
      var dt = clamp(time / duration, 0, 1);
      pixelColor = texture.get(vec2(clamp(calculatedUV.x - cos(time + calculatedUV.y * 50 * dt) * 0.05 * dt, 0, 1), calculatedUV.y));
      pixelColor = pixelColor.a * pixelColor + (1 - pixelColor.a) * vec4(bg, 1);
      
      var a = 1 - dt * dt * dt;
      // pixelColor.r = dt;
      // pixelColor.gb = vec2(0, 0);
      pixelColor *= a;
    }
  }
  
}

private typedef CircleShader = ldx.shader.SDFCircle;

#if test_loader
class DummyManifest extends cherry.fs.ManifestFileSystem {
  
  var loop:haxe.MainLoop.MainEvent;
  
  public function new() {
    super("res", haxe.io.Bytes.ofString("[]"));
    var count = 10;
    
    inline function insert(path:String, file:String, original:String):Void
    {
      var dir:Array<String> = haxe.io.Path.directory(original).split('/');
      var r = root;
      for (n in dir)
      {
        if (n == "") continue;
        var found:Bool = false;
        for (c in r.contents)
        {
          if (c.name == n)
          {
            r = c;
            found = true;
            break;
          }
        }
        if (!found)
        {
          var dirEntry = new cherry.fs.ManifestFileSystem.ManifestEntry(this, n, r.relPath + "/" + n, null);
          r.contents.push(dirEntry);
          r = dirEntry;
        }
      }
      var entry = new DummyLoader(this, haxe.io.Path.withoutDirectory(original), original, file, original);
      r.contents.push(entry);
      manifest.set(path, entry);
    }
    
    for (i in 0...count) {
      insert("dummy" + i + ".ext", "dummy" + i + ".ext", "dummy" + i + ".ext");
    }
    loop = haxe.MainLoop.add(update);
  }
  
  function update() {
    var total = 0;
    var loaded = 0;
    for (e in manifest) {
      var dummy = cast (e, DummyLoader);
      total++;
      if (dummy.loading && dummy._loaded >= dummy._size) loaded++;
      
      if (dummy.loading && dummy._loaded < dummy._size) {
        dummy._loaded += Std.int(Math.random() * 10);
        if (dummy._loaded >= dummy._size) {
          dummy.ready();
        } else {
          dummy.progress(dummy._loaded, dummy._size);
        }
      }
    }
    if (total == loaded) loop.stop();
  }
  
}

private class DummyLoader extends cherry.fs.ManifestFileSystem.ManifestEntry {
  
  public var loading:Bool;
  public var _size:Int;
  public var _loaded:Int;
  public var ready:Void->Void;
  public var progress:Int->Int->Void;
  
  override public function fancyLoad(onReady:() -> Void, onProgress:(cur:Int, max:Int) -> Void)
  {
    this._loaded = 0;
    this._size = Std.int(Math.random() * 1500) + 500;
    loading = true;
    ready = onReady;
    progress = onProgress;
  }
  
  override function get_size():Int
  {
    return _size;
  }
  
}

#end