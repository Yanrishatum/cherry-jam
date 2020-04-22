import h2d.Font;
import State;
import hxd.res.Sound;
import haxe.io.Path;
import hxd.Music;
import hxd.snd.ChannelGroup;
import hxd.snd.SoundGroup;
import dn.M;
import h2d.Bitmap;
import hxd.Res;
import h2d.Tile;

class R {
  
  public static var a:Tile;
  public static var b:Tile;
  public static var font:h2d.Font;
  public static var digits:h2d.Font;
  public static inline var W:Int = 320;
  public static inline var H:Int = 180;
  
  public static var music:ChannelGroup = new ChannelGroup("music");
  public static var sfx:ChannelGroup = new ChannelGroup("sfx");
  
  public static var unlocks:Array<Evolution> = [EvoBase];
  
  public static function init() {
    a = Res.atlas.toTile();
    b = Res.sprites.toTile();
    music.volume = 0.3;
    sfx.volume = 0.3;
    // clickGroup.maxAudible = 1;
    Music.channelGroup = music;
    
    @:privateAccess {
      font = new h2d.Font("main", 10, BitmapFont);
      font.tile = Res.font.toTile();
      final fh = 11;
      font.lineHeight = 10;
      font.baseLine = 9;
      var str = "ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n1234567890.,:;?!-+=~*`'\"#$%[]/|\\<>";
      var pix = Res.font.toBitmap();
      var y = 0, x = 0;
      var i = 0;
      while (i < str.length) {
        var char = str.charCodeAt(i++);
        if (char == "\n".code) {
          x = 0; y += fh + 1;
          continue;
        }
        var sx = x;
        var col:Int;
        do {
          col = pix.getPixel(x, y);
          if (col == 0xff00ff00) {
            break;
          }
          x++;
        } while (x < pix.width);
        var w = x - sx;
        font.glyphs.set(char, new FontChar(font.tile.sub(sx, y, w, fh, 0), w-1));
        // trace(str.charAt(i-1), x, y, w, fh);
        x++;
      }
      font.glyphs.set(' '.code, new FontChar(font.tile.sub(187,12,0,0), 3));
      font.defaultChar = font.nullChar = font.glyphs.get('!'.code);
      
      digits = new h2d.Font("digits", 7, BitmapFont);
      digits.tile = a;
      digits.lineHeight = 7;
      digits.baseLine = 7;
      digits.glyphs.set('*'.code, new FontChar(a.sub(254, 30, 5, 7), 4));
      for (i in '0'.code ... ('9'.code+1)) {
        digits.glyphs.set(i, new FontChar(a.sub(260 + (i - '0'.code) * 6, 30, 5, 7), 4));
      }
    }
    
    loadSettings();
  }
  
  static var SAVEPATH:String = #if hl Path.join([Sys.getEnv("APPDATA"), "cherrysoup/ld46/settings"]) #else "ld46/settings" #end ;
  
  public static function saveSettings() {
    #if hl
    sys.FileSystem.createDirectory(Path.directory(SAVEPATH));
    #end
    hxd.Save.save({
      music: music.volume,
      musicMute: music.mute,
      sfx: sfx.volume,
      sfxMute: sfx.mute,
      unlocks: unlocks
    }, SAVEPATH);
  }
  
  public static function loadSettings() {
    var data = hxd.Save.load(null, SAVEPATH);
    if (data != null) {
      music.volume = data.music;
      music.mute = data.musicMute;
      sfx.volume = data.sfx;
      sfx.mute = data.sfxMute;
      if (data.unlocks != null) unlocks = data.unlocks;
    }
  }
  
  public static function xsub(x:Int, y:Int, w:Int, h:Int, count:Int, sx:Int = 1, dx:Float=0, dy:Float=0) {
    sx += w;
    return [for (i in 0...count) a.sub(x + i * sx, y, w, h, dx, dy)];
  }
  
  public static function ysub(x:Int, y:Int, w:Int, h:Int, count:Int, sy:Int = 1, dx:Float=0, dy:Float=0) {
    sy += h;
    return [for (i in 0...count) a.sub(x, y + i * sy, w, h, dx, dy)];
  }
  
  public static function glow(w, h, col:Int, ?parent):Bitmap
  {
    var t = Res.glow_rad.toTile();
    t.scaleToSize(w, h);
    t.setCenterRatio();
    var b = new Bitmap(t, parent);
    b.color.setColor(0xff000000 | col);
    return b;
  }
  
  static var clickGroup:SoundGroup = new SoundGroup("click");
  public static function click() {
    Res.sound.button.play(false, 1, sfx, clickGroup);
  }
  public static function clickE(_) inline click();
  
  public static function s(snd:Sound) {
    return snd.play(false, 1, sfx);
  }
  
  public static function txt(?parent, ?customColors:Map<Int, Int>) {
    var t = new h2d.Text(R.font, parent);
    t.letterSpacing = 0;
    t.addShader(new comps.PaletteShader(customColors != null ? customColors : [ 0xffffff => 0xff8888aa, 0x090910 => 0xff090910 ]));
    return t;
  }
  
}

typedef EvoTree = {
  var name:Evolution;
  var leafs:Array<EvoTree>;
}