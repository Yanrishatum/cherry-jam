package game.comps;

import engine.Music;
import hxd.Event;
import game.comps.GameUI;
import hxd.Key;
import engine.Locale;
import hxd.res.Resource;
import hxd.res.Image;
import h2d.Tile;
import h2d.Bitmap;
import hxd.Res;
import h2d.Interactive;
import h2d.Text;
import gasm.heaps.components.HeapsSpriteComponent;
import h2d.Object as Sprite;
import engine.HXP;
import engine.HComp;
import engine.utils.Tween;

class VNDisplay extends HComp
{
  
  private var sprite:Sprite;
  
  private var text:Text;
  private var skip:Interactive;
  
  private var portraits:Map<String, VNPortrait>;
  private var script:Tsv;
  private var scriptPos:Int;
  
  public var shown:Bool;
  public var battle:BattleScene;
  private var chain:Resource;
  
  public function new(battle:BattleScene)
  {
    super();
    this.battle = battle;
    HXP.wrap(this);
  }
  
  override public function setup()
  {
    super.setup();
    var rnd:HeapsSpriteComponent = new HeapsSpriteComponent();
    owner.add(rnd);
    
    sprite = new Sprite(rnd.sprite);
    // bg
    var bgTile:Tile = Res.vnbg.toTile();
    var bg:Bitmap = new Bitmap(bgTile, sprite);
    
    text = new Text(Res.el_messiri_regular_22.toFont(), sprite);
    text.maxWidth = 1200;
    text.color.setColor(GameUI.color);
    text.x = 40;
    text.y = 30;
    
    var inter:Interactive = new Interactive(1280, bgTile.height, sprite);
    inter.onClick = nextClick;
    var skip:TextButton = new TextButton("skip", null, 100, sprite);
    skip.x = 1280 - 140;
    skip.y = bgTile.height - 60;
    skip.onClick = skipClick;
    
    portraits = [
      "gale" => new VNPortrait("gale", [
        "normal" => Res.emo.gale_normal,
        "rage" => Res.emo.gale_rage,
        "surprise" => Res.emo.gale_surprise
      ], sprite),
      "inori" => new VNPortrait("inori", [
        "normal" => Res.emo.inori_normal,
        "fright" => Res.emo.inori_fright
      ], sprite),
      "ricard" => new VNPortrait("ricard", [
        "normal" => Res.emo.ricard_normal,
        "rage" => Res.emo.ricard_rage
      ], sprite),
      "violette" => new VNPortrait("violette", [
        "normal" => Res.emo.violette_normal,
        "blank" => Res.emo.violette_blank,
        "anger" => Res.emo.violette_anger
      ], sprite),
    ];
    sprite.visible = false;
    // skip
  }
  
  
  override public function init()
  {
    sprite.y = 720 - Res.vnbg.getSize().height;
    
    var btm = new h2d.Bitmap(Tile.fromColor(0, 1280, 720, 0.3));
    btm.x = -sprite.x;
    btm.y = -sprite.y;
    sprite.addChildAt(btm, 0);
  }
  
  private function skipClick(e:Event):Void
  {
    hide();
  }
  
  private function nextClick(e:Event):Void
  {
    nextPos();
  }
  
  public function show(r:Resource, ?chain:Resource)
  {
    for (p in portraits)
    {
      p.hide(true);
    }
    script = Tsv.parse(r.entry.getText());
    this.chain = chain;
    sprite.visible = true;
    scriptPos = -1;
    shown = true;
    battle.updateAtb = false;
    nextPos();
  }
  
  private function nextPos():Void
  {
    scriptPos++;
    if (scriptPos < script.list.length)
    {
      var char:String = script.get(scriptPos, 0);
      text.text = Locale.get(char) + "\n" + script.get(scriptPos, 3, true);
      var pos:String = script.get(scriptPos, 2);
      for (p in portraits)
      {
        if (p.name == char)
        {
          p.lighten();
          var emo:String = script.get(scriptPos, 1);
          p.show(emo == "" ? null : emo);
          switch(pos)
          {
            case 'left': p.setPos(0, !p.visible);
            case 'center': p.setPos(1, !p.visible);
            case 'right': p.setPos(2, !p.visible);
            case 'hide': p.hide(false);
            case 'darken': p.darken();
            case 'lighten': p.lighten();
          }
        }
        else
        {
          p.darken();
        }
      }
      if (StringTools.rtrim(script.get(scriptPos, 3)) == "#skip")
      {
        nextPos();
      }
    }
    else 
    {
      hide();
    }
  }
  
  private function hide()
  {
    if (chain != null)
    {
      show(chain);
      return;
    }
    sprite.visible = false;
    battle.updateAtb = true;
    shown = false;
    if (Main.flags.indexOf("intro") == -1)
    {
      Main.flags.push("intro");
      #if js
        Music.play("fight_thing.mp3");
      #else
        Music.play(Res.sfx.music.fight_thing);
      #end
    }
    if (Main.flags.indexOf("victory") != -1 || Main.flags.indexOf("defeat") != -1)
    {
      HXP.engine.scene = new MenuScene();
    }
  }
  
  override public function update(delta:Float)
  {
    if (!sprite.visible) return;
    for (p in portraits)
    {
      p.update(delta);
    }
    if (Key.isReleased(Key.SPACE))
    {
      nextPos();
    }
    if (Key.isReleased(Key.ESCAPE))
    {
      skipClick(null);
    }
  }
  
}

class VNPortrait extends Sprite
{
  private static inline var colorMul:Float = 3;
  private var curColor:Float = 1;
  private var targetColor:Float = 1;
  private var targetPos:Float = 0;
  private var targetAlpha:Float = 1;
  private var startPos:Float = 0;
  
  private var ports:Map<String, h2d.Bitmap>;
  private var w:Int;
  
  private var tween:Tween;
  
  public function new(name:String, ress:Map<String, Image>, ?parent:Sprite)
  {
    super(parent);
    ports = new Map();
    w = 0;
    for (k in ress.keys())
    {
      var t = ress[k].toTile();
      w = HXP.max(t.iwidth, w);
      var portrait = new h2d.Bitmap(t, this);
      portrait.y = -t.height;
      portrait.visible = false;
      ports[k] = portrait;
    }
    tween = new Tween(0.8);
    this.name = name;
    visible = false;
  }
  
  public function hide(fast:Bool):Void
  {
    if (fast) visible =false;
    else targetAlpha = 0;
  }
  
  public function show(emo:String):Void
  {
    if (emo == null) emo = "normal";
    if (!ports.exists(emo))
    {
      trace("NO EMO FOUND: " + emo);
      emo = "normal";
    }
    for (k in ports.keys())
    {
      if (k == emo)
      {
        ports[k].visible = true;
      }
      else ports[k].visible = false;
    }
    
    if (!visible)
    {
      targetAlpha = 1;
      visible = true;
      alpha = 0;
    }
  }
  
  public function left():Void
  {
    targetPos = 20;
    startPos = this.x;
    tween.start();
  }
  
  public function center():Void
  {
    targetPos = (1280 - w) / 2;
    startPos = this.x;
    tween.start();
  }
  
  public function right():Void
  {
    targetPos = 1280-w;
    startPos = this.x;
    tween.start();
  }
  
  public function setPos(slot:Int, fast:Bool):Void
  {
    switch(slot)
    {
      case 0: left();
      case 1: center();
      case 2: right();
    }
    if (fast)
    {
      this.x = targetPos;
      tween.working = false;
    }
  }
  
  public function darken():Void
  {
    targetColor = 0.5;
  }
  
  public function lighten():Void
  {
    targetColor = 1.0;
    parent.addChildAt(this, parent.children.length);
  }
  
  public function update(delta:Float):Void
  {
    if (targetAlpha != alpha)
    {
      alpha = HXP.moveTowards(alpha, delta * colorMul, targetAlpha);
      if (alpha == 0) visible = false;
      else visible = true;
    }
    if (targetColor != curColor)
    {
      curColor = HXP.moveTowards(curColor, delta * colorMul, targetColor);
      for (p in ports) p.color.set(curColor, curColor, curColor);
    }
    if (tween.working)
    {
      tween.update(delta);
      this.x = startPos + (targetPos - startPos) * engine.utils.Ease.backOut(tween.percent);
    }
  }
  
}