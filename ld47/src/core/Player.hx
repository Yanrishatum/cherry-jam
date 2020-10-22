package core;

import hxd.snd.Channel;
import h2d.col.Point;
import h2d.Bitmap;
import hxd.Timer;
import h2d.Tile;
import ch2.Animation;
import ch2.AnimationExt;
import h2d.RenderContext;
import hxd.Res;
import h2d.Text;
import differ.shapes.Circle;
import hxd.Key;
import ldx.Updateable;
import core.Replay;
import h2d.Object;
import core.DeathFilter;

class Player extends Updateable {
  
  public var provider:InputProvider;
  public var slot:Int;
  public var collider:Circle;
  public var isMain:Bool;
  
  public var anim:AnimationExt;
  
  public var vx:Float;
  public var vy:Float;
  
  public var interacting:Int;
  var footsteps:Channel;
  
  public function new(provider:InputProvider, slot:Int, ?parent) {
    super(1, parent);
    this.provider = provider;
    this.slot = slot;
    this.collider = new Circle(0, 0, 8);
    this.isMain = Std.isOfType(provider, RawInput);
    
    var frames = Res.player.toTile().gridFlatten(114, -57, -85);
    anim = new AnimationExt(this);
    final fps = 4;
    function make(name, fr:Array<Tile>) {
      var d = new AnimationDescriptor(Animation.fromFixedFramerate(fr, fps));
      d.loop = true;
      anim.animations.set(name + "r", d);
      var left = [for (t in fr) t.clone()];
      for (f in left) f.flipX();
      d = new AnimationDescriptor(Animation.fromFixedFramerate(left, fps));
      d.loop = true;
      anim.animations.set(name + "l", d);
    }
    make("mw_u", [frames[0], frames[1]]);
    make("cw_u", [frames[2], frames[3]]);
    make("mw_d", [frames[4], frames[5]]);
    make("cw_d", [frames[6], frames[7]]);
    make("mi_u", [frames[0]]);
    make("ci_u", [frames[2]]);
    make("mi_d", [frames[4]]);
    make("ci_d", [frames[6]]);
    anim.playAnim(isMain ? "mi_dr" : "ci_dr");
    anim.scale(0.7);
  }
  
  override function onAdd()
  {
    super.onAdd();
    footsteps = Res.sound.FOOTSTEPS_LOOP.sfx(true, 0.5);
    footsteps.position = Math.random() * footsteps.duration;
  }
  
  override function onRemove()
  {
    super.onRemove();
    footsteps.stop();
  }
  
  var pressedUse:Int = 0;
  override public function fixedUpdate()
  {
    if (filter != null) return; // Do nothing
    var name = anim.currentAnimation;
    if (provider.hasNext()) {
      var f = provider.next();
      var dx = (f.isDown(Key.A) || f.isDown(Key.LEFT)) ? -1 : 0;
      if (f.isDown(Key.D) || f.isDown(Key.RIGHT)) dx++;
      var dy = (f.isDown(Key.W) || f.isDown(Key.UP)) ? -1 : 0;
      if (f.isDown(Key.S) || f.isDown(Key.DOWN)) dy++;
      
      this.vx += dx * State.speed;
      this.vy += dy * State.speed;
      this.collider.x = this.vx;
      this.collider.y = this.vy;
      
      var na = isMain ? "m" : "c";
      if (dx == 0 && dy == 0) {
        na += "i_" + name.substr(-2);
      } else {
        na += "w_";
        if (dy == 0) na += name.substr(-2, 1);
        else na += (dy > 0 ? 'd' : 'u');
        if (dx == 0) na += name.substr(-1, 1);
        else na += (dx > 0 ? 'r' : 'l');
      }
      name = na;
      
      if (f.isPressed(Key.E) || f.isPressed(Key.ENTER) || f.isPressed(Key.X) || (interacting == 0 && pressedUse > 0)) {
        pressedUse = 4;
        State.game.interact(this);
      }
      pressedUse--;
    } else {
      if (filter == null) 
        // filter = new h2d.filter.Bloom();
        filter = new DeathFilter();
      // this.visible = false;
      // this.vx = 0;
      // this.vy = 0;
      // TODO: Disintegrate
    }
    if (name != anim.currentAnimation) anim.playAnim(name);
  }
  
  public function posAt(x:Float, y:Float) {
    this.x = x;
    this.vx = x;
    this.y = y;
    this.vy = y;
    this.collider.x = this.vx;
    this.collider.y = this.vy;
    interacting = 0;
    alpha = 1;
    visible = true;
    filter = null;
  }
  
  override function sync(ctx:RenderContext)
  {
    var dx = hxd.Math.lerp(this.x, vx, ctx.elapsedTime * 10);
    var dy = hxd.Math.lerp(this.y, vy, ctx.elapsedTime * 10);
    this.x = dx;
    this.y = dy;
    if (interacting > 0) {
      var s = Math.cos(hxd.Timer.lastTimeStamp * 10);
      rotation = s > 0 ? 0.1 : -0.1;
    } else rotation = 0;
    if (anim.currentAnimation.indexOf("i_") == -1 && !anim.pause)
      footsteps.volume = hxd.Math.clamp(0.5 - hxd.Math.distance(x - State.game.player.x, y - State.game.player.y) / 200 / 2, 0, 0.5);
    else footsteps.volume = 0;
    if (filter != null) {
      var d = cast(filter, DeathFilter);
      this.alpha = 1 - d.shader.time;
      if (d.shader.time > 1) {
        filter = null;
        if (this == State.game.player) {
          State.game.finishCycle();
        } else {
          this.vx = 0;
          this.vy = 0;
          this.visible = false;
        }
      }
    }
    super.sync(ctx);
  }
  
}

class PlayerReplay extends Player {
  
  public var replay:Replay;
  public var view:ReplayView;
  
  public static var slotColors:Array<Int> = [0xff8888, 0x88ff88, 0x8888ff, 0xff88ff, 0x88ffff];
  
  public function new(replay:Replay, slot:Int, ?parent) {
    this.replay = replay;
    super(replay, slot, parent);
    anim.color.setColor(0xff000000 | slotColors[slot]);
  }
  
  override function sync(ctx:RenderContext)
  {
    if (State.game.timer.time < State.startInvincibility) alpha = (Timer.lastTimeStamp % .6) > 0.3 ? 0.7 : 1;
    else alpha = 1;
    super.sync(ctx);
  }
  
  override function onAdd()
  {
    super.onAdd();
    replay.start();
    view = new ReplayView(replay, slotColors[slot]);
    State.game.root.add(view, State.game.playerLayer - 1);
  }
  
  override function onRemove()
  {
    super.onRemove();
    view.remove();
  }
  
}

class TheE extends Bitmap {
  
  public function new(?parent) {
    super(Res.interact.toTile(), parent);
    tile.scaleToSize(tile.width / 3, tile.height / 3);
    tile.setCenterRatio();
  }
  
  override function sync(ctx:RenderContext)
  {
    super.sync(ctx);
    var p = State.game.player;
    var pt = new Point(p.x, p.y);
    State.camera.cameraToScene(pt);
    x = pt.x - tile.width - 2;
    y = pt.y - tile.height / 2;
    
    var s = Math.sin(hxd.Timer.lastTimeStamp * 10);
    rotation = s > 0 ? 0.1 : -0.1;
  }
  
}