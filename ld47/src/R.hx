import ldx.shader.Explosion;
import hxd.snd.SoundGroup;
import h2d.HtmlText;
import hxd.res.BitmapFont;
import hxd.Res;
import haxe.io.Path;
import cherry.Music;
import h2d.Font;
import hxd.snd.ChannelGroup;

class R {
  
  public static inline var JAM_NAME = "ld47";
  public static inline var LOADER_LAYER:Int = 11;
  public static inline var MENU_LAYER:Int = 10;
  public static inline var UI_LAYER:Int = 9;
  
  public static inline var ACTIVE_COLOR:Int = 0xffa43e33;
  public static inline var IDLE_COLOR:Int = 0xff4b423d;
  public static inline var TEXT_COLOR:Int = 0xffE3E3E3;
  
  public static var music:ChannelGroup = new ChannelGroup("music");
  public static var sfx:ChannelGroup = new ChannelGroup("sfx");
  
  public static var alarmGroup:SoundGroup = { var g = new SoundGroup("alarm"); g.maxAudible = 1; g; }
  public static var bigAlarmGroup:SoundGroup = { var g = new SoundGroup("alarm2"); g.maxAudible = 1; g; }
  
  public static var fontResource:BitmapFont;
  public static var font:Font;
  
  static var SAVEPATH:String = #if hl Path.join([Sys.getEnv("APPDATA"), "cherrysoup/", JAM_NAME, "/settings"]) #else JAM_NAME + "/settings" #end ;
  
  static function saveExtras():Dynamic {
    return {
      
    };
  }
  
  static function loadExtras(data:Dynamic) {
    
  }
  
  public static function saveSettings() {
    #if hl
    sys.FileSystem.createDirectory(Path.directory(SAVEPATH));
    #end
    hxd.Save.save({
      music: music.volume,
      musicMute: music.mute,
      sfx: sfx.volume,
      sfxMute: sfx.mute,
      data: saveExtras()
    }, SAVEPATH);
  }
  
  public static function loadSettings() {
    var data = hxd.Save.load(null, SAVEPATH);
    if (data != null) {
      music.volume = data.music;
      music.mute = data.musicMute;
      sfx.volume = data.sfx;
      sfx.mute = data.sfxMute;
      loadExtras(data.data);
    }
  }
  
  public static function getFont(size:Int) {
    return fontResource.toSdfFont(size, MultiChannel, 0.5, 1 / (size * .8));
  }
  
  public static function getSDF(font:BitmapFont, size:Int) {
    return font.toSdfFont(size, MultiChannel, 0.5, 1 / (size * .8));
  }
  
  static function loadFont(name:String) {
    var d = name.split("-");
    if (d[0] == "size" && d.length == 2) {
      return getFont(Std.parseInt(d[1]));
    } else if (Res.loader.exists(d[0])) {
      var fnt = Res.load(d[0]).to(hxd.res.BitmapFont);
      return fnt.toFont(); // TODO: SDF process
    }
    if (d.length == 2) return getFont(Std.parseInt(d[1]));
    return font;
  }
  
  @:noCompletion
  public static function init() {
    if (font == null) {
      fontResource = Res.ldx.ptsans;
      font = getFont(14);
      HtmlText.defaultLoadFont = loadFont;
      // font = fontResource.toSdfFont(14, MultiChannel, 0.5, 1 / 14 * .8);
      // font = hxd.res.DefaultFont.get();
      Music.channelGroup = music;
    }
    sfx.volume = 0.5;
    music.volume = 0.5;
    Explosion.generate();
    R.loadSettings();
  }
  
}