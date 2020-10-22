package ldx;

import h2d.Tile;
import core.GameTimer;
import h2d.Object;
import h2d.filter.Outline;
import scenes.MenuScene;
import h2d.Interactive;
import core.Dialogue;
import core.Player;
import hxd.Res;
import h2d.Bitmap;
import hxd.Key;
import h2d.RenderContext;
import ch2.ui.DevUI;
import h2d.Layers;

class GameUI extends Layers {
  
  #if debug
  public var ov:DevUI;
  #end
  
  var shipBG:Bitmap;
  var ship:Bitmap;
  var hp:Bitmap;
  var clock:Bitmap;
  var icons:Array<{ b:Bitmap, t:Float }>;
  var lineSize:Float;
  var lineOffset:Float;
  
  var wasd:Array<Bitmap>;
  public var e:TheE;
  public var dialogue:Dialogue;
  
  public function new() {
    super();
    State.s2d.add(this, R.UI_LAYER);
    
    var c = new Bitmap(Res.clock.toTile().center(), this);
    // c.scale(0.7);
    // c.setPosition((c.tile.iwidth >> 1) + 2, (c.tile.iheight >> 1) + 2);
    c.setPosition((c.tile.iwidth >> 1) * (1 / 0.7) + 2, (c.tile.iheight >> 1) * (1 / 0.7) + 2);
    clock = new Bitmap(Res.clock_arrow.toTile(), c);
    clock.tile.dx = -7;
    clock.tile.dy = -23;
    // clock.tile.dx = -10;
    // clock.tile.dy = -30;
    
    var at = Res.alert.toTile();
    var a = new Interactive(at.width, at.height, this);
    a.onClick = (e) -> {
      new MenuScene();
    }
    new Bitmap(at, a);
    a.x = 1280 - c.x - a.width + (c.tile.iwidth >> 1);
    a.y = c.y - (c.tile.iheight >> 1);
    
    var bg = shipBG = new Bitmap(Res.progress_bar.toTile(), this);
    bg.x = Std.int((1280 - bg.tile.width) / 2);
    bg.y = 26;
    
    lineSize = shipBG.tile.width - 50;
    lineOffset = 25;
    
    hp = new Bitmap(Res.progress_hp.toTile(), bg);
    hp.y = bg.tile.height - hp.tile.height;
    
    ship = new Bitmap(Res.miniship.toTile().center(), bg);
    ship.y = (bg.tile.iheight >> 1) - 3;
    ship.x = 25;
    
    dialogue = new Dialogue(this);
    e = new TheE(this);
    icons = [];
    
    var frames = Res.controls.toTile().split(5);
    var wc = new Object(this);
    wc.setPosition(1280>>1, 250);
    wc.scale(0.33);
    wasd = [
      new Bitmap(frames[0].center(), wc),
      new Bitmap(frames[1].center(), wc),
      new Bitmap(frames[2].center(), wc),
      new Bitmap(frames[3].center(), wc),
      // new Bitmap(frames[4].center(), wc),
    ];
    final xx = 126;
    wasd[0].setPosition(0, 0);
    wasd[1].setPosition(-xx, xx);
    wasd[2].setPosition(0, xx);
    wasd[3].setPosition(xx, xx);
    // wasd[4].setPosition(xx, 0);
    
    #if debug
    ov = new DevUI();
    // ov.scale
    ov.visible = false;
    ov.autoWatch = true;
    add(ov, 3);
    
    // 
    ov.checkbox(() -> false, (v) -> State.game.timer.time = 55, "Almost win");
    ov.checkbox(() -> false, (v) -> State.hp = State.maxHP, "Full HP");
    ov.checkbox(() -> false, (v) -> State.hp = 1, "Almost dead");
    
    #end
  }
  
  public function cycle() {
    for (i in icons) i.b.remove();
    icons = [];
    
    function doIcon(i:Tile, id:String) {
      for (t in State.game.triggers) {
        if (t.name == id) {
          var btm = new Bitmap(i, shipBG);
          btm.x = (t.appearAt / State.surviveTime) * lineSize + lineOffset;
          btm.y = shipBG.tile.iheight>>1;
          icons.push({ b:btm, t:t.appearAt });
          break;
        }
      }
    }
    if (State.triggered.get('lightning_rod_appear') >= 1) doIcon(Res.minithunder.toTile().center(), 'lightning_rod');
    if (State.triggered.get('cannon_appear') >= 1) doIcon(Res.minimoth.toTile().center(), 'cannon');
    if (State.triggered.get('wheel_appear') >= 1) doIcon(Res.minirocks.toTile().center(), 'wheel');
    shipBG.addChild(ship);
    
    var head = Res.head.toTile().center();
    var out = Res.head_outline.toTile().center();
    for (r in State.game.echos) {
      
      var btm = new Bitmap(out, shipBG);
      btm.setPosition(
        (r.replay.time / State.surviveTime) * lineSize + lineOffset,
        shipBG.tile.iheight>>1
      );
      var inner = new Bitmap(head, btm);
      btm.alpha = 0;
      inner.color.setColor(0xff000000 | PlayerReplay.slotColors[r.slot]);
      icons.push({ b:btm, t:r.replay.time });
    }
    var vis = State.iteration == 0;
    for (w in wasd) w.visible = vis;
  }
  
  override function sync(ctx:RenderContext)
  {
    #if debug
    if (Key.isReleased(Key.Q)) ov.visible = !ov.visible;
    #end
    var i = 0;
    if (State.iteration == 0)
    {
      if (GameTimer.frame > 20) for (w in wasd) w.visible = false;
      else {
        for (w in wasd) {
          var s = Math.sin((hxd.Timer.lastTimeStamp + wasd.indexOf(w)) * 10);
          w.rotation = s > 0 ? 0.1 : -0.1;
        }
      }
    }
    while (i < icons.length) {
      var ii = icons[i++];
      var ic = ii.b;
      var target = (ii.t > State.game.timer.time) ? 1 : 0.5;
      if (ic.alpha < target) {
        ic.alpha += ctx.elapsedTime * 2;
        if (ic.alpha > target) ic.alpha = target;
      } else if (ic.alpha > target) {
        ic.alpha -= ctx.elapsedTime * 2;
        if (ic.alpha < target) ic.alpha = target;
      }
    }
    clock.rotation = hxd.Math.lerp(clock.rotation, (State.game.timer.time / 2) * (Math.PI*2), 0.05);
    ship.x = hxd.Math.lerp(ship.x, Std.int((State.game.timer.time / State.surviveTime) * (lineSize) + lineOffset), 0.05);
    hp.tile.setSize(hxd.Math.lerp(hp.tile.width, 9 + (shipBG.tile.width - 9 - 9) * (State.hp / State.maxHP), 0.05), hp.tile.height);
    super.sync(ctx);
  }
  
}