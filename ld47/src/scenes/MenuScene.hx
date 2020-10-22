package scenes;

import hxd.Window;
import ldx.comps.MenuButton;
import h2d.ScaleGrid;
import h3d.shader.SignedDistanceField;
import hxd.Res;
import h2d.Bitmap;
import h2d.HtmlText;
import ldx.RedRay;
import ch2.ui.RadioButton;
import h2d.Text;
import h2d.Tile;
import h2d.Flow;
import h2d.Interactive;
import dn.Process;

class MenuScene extends Process {
  
  var flow:Flow;
  var caret:RedRay;
  var caretIndex:Int = 0;
  
  static inline var spacing:Float = 26;
  
  override public function init()
  {
    super.init();
    
    if (State.game != null && !State.game.destroyed) State.game.pause();
    if (State.menu != null && !State.menu.destroyed) State.menu.destroy();
    State.menu = this;
    
    var s2d = State.s2d;
    createRootInLayers(s2d, R.MENU_LAYER);
    
    // Basic menu
    
    // Backdrop
    if (State.game != null && !State.game.destroyed) {
      var backdrop = new Interactive(s2d.width, s2d.height, root);
      backdrop.cursor = Default;
      backdrop.backgroundColor = 0xff111111;
      backdrop.alpha = 0.66;
    }
    
    var r = flow = new Flow(root);
    // r.backgroundTile = Tile.fromColor(0x333333);
    r.horizontalAlign = Middle;
    r.layout = Vertical;
    r.paddingVertical = 10;
    r.paddingHorizontal = 60;
    r.verticalSpacing = 6;
    r.maxWidth = (s2d.width >> 1);
    
    r.borderHeight = 32;
    r.borderWidth = 32;
    r.backgroundTile = Utils.allocSDFTile(128, 128, 0x333333);
    var sdf = new ldx.shader.SDFRect();
    sdf.radius = 8 / 128;
    @:privateAccess r.background.addShader(sdf);
    
    caret = new RedRay(false, r);
    caret.center();
    caret.fitInto(100, 100);
    caret.x = 15;
    r.getProperties(caret).isAbsolute = true;
    
    final labelWidth = 60;
    
    var offset = 0;
    if (State.game != null && !State.game.destroyed) {
      var cont = new MenuButton("continue", r);
      cont.onOverEvent.add((e) -> moveCaret(0));
      cont.onClick = (e) -> {
        destroy();
        State.game.resume();
      }
      offset = 1;
    }
    var ng = new MenuButton("new_game", r);
    ng.onOverEvent.add((e) -> moveCaret(offset));
    ng.onClick = (e) -> {
      destroy();
      if (State.game != null && !State.game.destroyed) State.game.destroy();
      CutsceneScene.showIntro();
      // new GameScene();
    }
    var tut = new MenuButton("tutorial", r);
    tut.onOverEvent.add((e) -> moveCaret(1 + offset));
    tut.onClick = (e) -> {
      var it = new Interactive(1280, 720, root);
      new Bitmap(Res.tutorial.toTile(), it);
      it.onClick = (e) -> it.remove();
    }
    var fs = new MenuButton("fullscreen", r);
    fs.onOverEvent.add((e) -> moveCaret(2 + offset));
    fs.onClick = (e) -> {
      var wnd = Window.getInstance();
      if (wnd.displayMode == Fullscreen || wnd.displayMode == Borderless) {
        wnd.displayMode = Windowed;
        #if js
        js.Browser.document.querySelector("#canvas-container").classList.remove("fullscreen");
        @:privateAccess wnd.checkResize();
        #end
      }
      else {
        wnd.displayMode = Fullscreen;
        #if js
        js.Browser.document.querySelector("#canvas-container").classList.add("fullscreen");
        @:privateAccess wnd.checkResize();
        #end
      }
    }
    
    var music = new ldx.comps.VolumeSlider("music", labelWidth, R.music, r);
    music.interactive.onOver = (e) -> moveCaret(3 + offset);
    var sfx = new ldx.comps.VolumeSlider("sfx", labelWidth, R.sfx, r);
    sfx.interactive.onOver = (e) -> moveCaret(4 + offset);
    
    var list = L.getLocaleList();
    if (list.length > 1) {
      var f = new Flow(r);
      f.horizontalSpacing = 4;
      f.verticalAlign = Top;
      r.getProperties(f).horizontalAlign = Left;
      var lbl = new Text(R.font, f);
      lbl.listenText("language");
      lbl.textAlign = Right;
      lbl.maxWidth = labelWidth;
      f.getProperties(lbl).minWidth = labelWidth;
      var g = new RadioGroup();
      for (l in list) {
        var btn = new ch2.ui.RadioButton(f, g, l.toUpperCase());
        btn.label.y -= 4;
        f.getProperties(btn).offsetY += 4;
      }
      g.selectedIndex = @:privateAccess L.current;
      g.onChange = function(idx) {
        L.changeRaw(idx);
      }
    }
    
    var credits = new HtmlText(R.font, r);
    credits.listenText("credits_text");
    credits.formatText = (t) -> StringTools.replace(StringTools.replace(t, "\n", ""), "\r", "");
    credits.textAlign = MultilineCenter;
    
    
    var size = r.getSize();
    r.x = Std.int((s2d.width - size.width) / 2);
    r.y = Std.int((s2d.height - size.height) / 2);
    update();
  }
  
  function moveCaret(idx:Int) {
    caretIndex = idx;
    caret.pointAt(flow.x + flow.paddingLeft + flow.borderWidth + 40, flow.y + flow.paddingTop + flow.borderHeight + idx * spacing + spacing);
  }
  
  override public function update()
  {
    var caretPos = flow.paddingTop + flow.borderHeight + caretIndex * spacing - 24;
    if (caret.y == 0) caret.y = caretPos;
    else caret.y = hxd.Math.lerp(caret.y, caretPos, dt / 10);
  }
  
  override public function onDispose()
  {
    L.unlistenAuto();
    R.saveSettings();
  }
  
}