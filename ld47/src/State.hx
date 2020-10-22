import hxd.Res;
import h2d.Camera;
import h2d.Font;
import scenes.GameScene;
import scenes.MenuScene;

class State {
  
  //#region base
  public static var app:Main;
  public static var window(get, never):hxd.Window;
  public static var engine(get, never):h3d.Engine;
  public static var s2d(get, never):h2d.Scene;
  public static var s3d(get, never):h3d.scene.Scene;
  public static var sevents(get, never):hxd.SceneEvents;
  
  public static var camera:Camera;
  public static var uiCamera:Camera;
  
  public static var menu:MenuScene;
  public static var game:GameScene;
  
  @:noCompletion
  public static function init() {
    final s2d = app.s2d;
    camera = s2d.camera;
    uiCamera = new Camera(s2d);
    s2d.interactiveCamera = uiCamera;
    camera.layerVisible = onlyGame;
    uiCamera.layerVisible = onlyUI;
  }
  
  static function onlyGame(layer:Int) {
    return layer != R.UI_LAYER && layer != R.MENU_LAYER && layer != R.LOADER_LAYER;
  }
  
  static function onlyUI(layer:Int) {
    return layer == R.UI_LAYER || layer == R.MENU_LAYER || layer == R.LOADER_LAYER;
  }
  
  static inline function get_window() return hxd.Window.getInstance();
  static inline function get_engine() return app.engine;
  static inline function get_s2d() return app.s2d;
  static inline function get_s3d() return app.s3d;
  static inline function get_sevents() return app.sevents;
  //#endregion
  
  public static function reset() {
    tea = 1;
    var j = Res.conf.toJson();
    speed = j.speed;
    surviveTime = j.survive_time;
    startInvincibility = j.invincibility;
    hp = maxHP = j.max_hp;
    iteration = 0;
    triggered = [];
  }
  
  public static var triggered:Map<String, Int>;
  public static var hp:Float;
  public static var iteration:Int;
  
  public static var maxHP:Float;
  public static var speed:Int;
  public static var surviveTime:Float;
  public static var startInvincibility:Float;
  public static var tea:Int;
  
}