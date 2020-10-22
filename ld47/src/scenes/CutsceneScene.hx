package scenes;

import cherry.Music;
import h2d.Interactive;
import h2d.filter.DropShadow;
import cherry.Ease;
import ch2.ui.effects.Appear;
import ch2.ui.RichText;
import hxd.Timer;
import h2d.Tile;
import h2d.SpriteBatch;
import h2d.Anim;
import h2d.Particles;
import hxd.Res;
import h2d.Bitmap;
import dn.Process;

class CutsceneScene extends Process {
  
  var bg:Anim;
  var text:RichText;
  var text2:RichText;
  var trash:Particles;
  var lines:SpriteBatch;
  var inter:Interactive;
  
  override public function init()
  {
    super.init();
    createRootInLayers(State.s2d, R.UI_LAYER);
    bg = new Anim([Res.title1.toTile(), Res.title2.toTile()], 10, root);
    // bg = new Bitmap(Res.title1.toTile(), root);
    //3 1
    //15 1
    
    
    // var app = new ShiftAppear(0, -30);
    // app.ease = Ease.backIn;
    text2 = new RichText(new RichTextFormat(R.getSDF(Res.nyarla, 48), 0x000000, .5, Center, null, []), root);
    // text = new RichText(new RichTextFormat(R.getFont(48), 0xdddde0, 1, Center, null, []), root);
    text2.maxWidth = 1000;
    text2.x = ((1280 - 1000) >> 1) + 2;
    
    text = new RichText(new RichTextFormat(R.getSDF(Res.nyarla, 48), 0xdddde0, 1, Center, null, []), root);
    // text = new RichText(new RichTextFormat(R.getFont(48), 0xdddde0, 1, Center, null, []), root);
    text.maxWidth = 1000;
    text.x = (1280 - 1000) >> 1;
    // text.filter = new DropShadow();
    // text.filter.boundsExtend += 10;
    
    trash = Res.trash.toParticles(root);
    trash.alpha = 0.8;
    var lt = Res.title_lines.toTile();
    var lf = lt.split(4);
    lines = new SpriteBatch(lt, root);
    for (i in 0...4) lines.add(new Line(lf[i]));
    // lines.blendMode = AlphaMultiply;
    lines.alpha = 0.6;
    lines.hasUpdate = true;
    var noise = new Bitmap(Res.noise.toTile(), root);
    noise.tileWrap = true;
    noise.addShader(new NoiseShader());
    
    inter = new Interactive(1280, 720, root);
    Utils.bgColor(0xff1f1e24);
  }
  
  public static function showIntro() {
    new CutsceneScene().show(['prologue_0', 'prologue_1'], [10, 10], () -> {
      Music.transit(Res.music.ld47theme, Res.music.intro_stop_ed);
      new GameScene();
    });
    Music.jingle(Res.music.intro_ed);
  }
  
  public function show(texts:Array<String>, times:Array<Float>, end:Void->Void) {
    var caret = -1;
    function next() {
      caret++;
      if (caret == texts.length) {
        destroy();
        end();
        return;
      }
      text.clear();
      text.addText(texts[caret].l());
      text.y = (720 - text.getSize().height) / 2;
      text2.clear();
      text2.addText(texts[caret].l());
      text2.y = (720 - text.getSize().height) / 2 + 2;
      var tmp = caret;
      Res.sound.slide_click.sfx();
      haxe.Timer.delay(() -> if (tmp == caret) next(), Std.int(times[caret] * 1000));
    }
    inter.onClick = (e) -> next();
    next();
  }
  
}

class Line extends BatchElement {
  
  var delay:Float;
  var speed:Float;
  var move:Float;
  
  public function new(t:Tile) {
    super(t);
    reset();
  }
  
  function reset() {
    delay = Math.random() * 4;
    move = Math.random() * 1;
    speed = Math.random() > 0.6 ? (Math.random() * 30) : 0;
    if (Math.random() > 0.5) speed *= -1;
    alpha = 0;
    x = Math.random() * 1280;
  }
  
  override function update(et:Float):Bool
  {
    if (delay > 0) {
      alpha = 0;
      delay -= Timer.elapsedTime;
    } else {
      alpha = 1;
      x += speed * Timer.elapsedTime;
      move -= Timer.elapsedTime;
      if (move < 0) reset();
    }
    return super.update(et);
  }
  
}

class NoiseShader extends hxsl.Shader {
  
  static var SRC = {
    
    @global var time:Float;
    @var var calculatedUV:Vec2;
    var textureColor:Vec4;
    var pixelColor:Vec4;
    
    function __init__() {
      calculatedUV += time;
    }
    
    function fragment() {
      var p = time % 1;
      var a:Float;
      if (p < 0.33) a = pixelColor.r;
      else if (p < 0.66) a = pixelColor.g;
      else a = pixelColor.b;
      pixelColor.rgb = vec3(1);
      pixelColor.a = a * .01;
    }
    
  }
  
}