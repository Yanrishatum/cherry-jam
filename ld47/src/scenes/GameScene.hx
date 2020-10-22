package scenes;

import cherry.Music;
import h2d.Object;
import core.DeathFilter;
import core.Clouds;
import core.Dialogue;
import h2d.Bitmap;
import core.Debris;
import hxd.Timer;
import differ.shapes.Circle;
import core.Trigger;
import ldx.GameUI;
import core.GameTimer;
import differ.data.ShapeCollision;
import differ.shapes.Polygon;
import h2d.col.Point;
import h2d.Graphics;
import h2d.col.IPoint;
import hxd.Res;
import core.Player;
import hxd.Key;
import core.Replay;
import h2d.Camera;
import ldx.IUpdateObject;
import dn.Process;
import ldx.Updateable;

@:access(h2d.Object)
class GameScene extends Process {
  
  public var updateables:Array<IUpdateObject> = [];
  
  public var ui:GameUI;
  public var timer:GameTimer;
  var spawns:Array<Point>;
  public var playerLayer:Int;
  public var player:Player;
  public var dialogue:Dialogue;
  public var echos:Array<PlayerReplay>;
  var levelCollider:Array<differ.shapes.Shape>;
  public var triggers:Array<Trigger>;
  var debris:Array<Debris>;
  var camMin:Float;
  var camMax:Float;
  
  override public function init()
  {
    fixedUpdateFps = Std.int(Timer.wantedFPS);
    super.init();
    State.game = this;
    createRootInLayers(State.s2d, 0);
    final s2d = root;
    // root = s2d;
    Utils.bgColor(0xff554f6b);
    
    ui = new GameUI();
    if (Music.current == null) Music.play(Res.music.ld47theme);
    
    timer = new GameTimer();
    timer.start();
    
    var data = Res.map.toMap();
    var s = 1.;
    // var mw = data.tmx.width * data.tmx.tileWidth * s;
    // var mh = data.tmx.height * data.tmx.tileHeight * s;
    var collider = new Array<differ.shapes.Shape>();
    
    spawns = [];
    triggers = [];
    debris = [];
    State.reset();
    
    var g = new h2d.Graphics(s2d);
    var l = 1;
    for (lt in data.tmx.layers) {
      switch (lt) {
        case LImageLayer(layer):
          var cloud = new Clouds();
          s2d.add(cloud, 0);
          var b = new h2d.Bitmap(Res.load(layer.image.source).toTile());
          s2d.add(b, l);
          b.setPosition(layer.offsetX, layer.offsetY);
        case LTileLayer(layer):
        case LObjectGroup(group):
          if (group.name == "Collisions") {
            
            for (o in group.objects) {
              switch (o.objectType) {
                case OTRectangle:
                  collider.push(differ.shapes.Polygon.rectangle(o.x, o.y, o.width, o.height, false));
                case OTPolygon(points):
                  // var polys = hxGeomAlgo.Bayazit.decomposePoly([for (pt in points) new hxGeomAlgo.HxPoint(pt.x, pt.y)]);
                  var polys = hxGeomAlgo.SnoeyinkKeil.decomposePoly([for (pt in points) new hxGeomAlgo.HxPoint(pt.x, pt.y)]);
                  for (p in polys) {
                    var col = new differ.shapes.Polygon(o.x, o.y, [for (pt in p) new differ.math.Vector(pt.x, pt.y)]);
                    collider.push(col);
                  }
                  // var ear = new hxd.earcut.Earcut();
                  // var tris = ear.triangulate(points);
                  // var i = 0;
                  // while (i < tris.length) {
                  //   var p = new differ.shapes.Polygon(o.x, o.y, [
                  //     new differ.math.Vector(points[tris[i]].x, points[tris[i]].y),
                  //     new differ.math.Vector(points[tris[i+1]].x, points[tris[i+1]].y),
                  //     new differ.math.Vector(points[tris[i+2]].x, points[tris[i+2]].y),
                  //   ]);
                  //   collider.push(p);
                  //   i += 3;
                  // }
                case OTEllipse:
                  collider.push(new differ.shapes.Circle(o.x + o.width / 2, o.y + o.width / 2, o.width / 2));
                default: throw "TODO: object type " + o.objectType;
              }
            }
            s2d.add(g, l);
          } else if (group.name == "Objects") {
            playerLayer = l;
            for (o in group.objects) {
              switch (o.name) {
                case "player":
                  for (i in 0...o.properties.getInt("count")) spawns.push(new Point(o.x, o.y));
                case "cam_center": State.camera.y = o.y;
                case "cam_left": camMin = o.x;
                case "cam_right": camMax = o.x;
                case "debris":
                  var d = new Debris(o);
                  s2d.add(d, l);
                  triggers.push(d);
                  debris.push(d);
                default:
                  var t = new Trigger(o);
                  s2d.add(t, l);
                  triggers.push(t);
              }
            }
          }
        default:
      }
      l++;
    }
    // var col = [0xff00];
    // var col = [0xff00, 0xf000, 0xea00, 0xe000];
    // var icol = 0;
    // for (p in collider) {
    //   g.beginFill(col[(icol++) % col.length], 0.5);
    //   if (Std.isOfType(p, Polygon)) {
    //     var p = cast(p, Polygon);
    //     for (pt in p.vertices) g.lineTo(p.x + pt.x, p.y + pt.y);
    //   } else if (Std.isOfType(p, Circle)) {
    //     var c = cast(p, Circle);
    //     g.drawCircle(c.x, c.y, c.radius);
    //   }
    // }
    // g.endFill();
    levelCollider = collider;
    
    player = new Player(new RawInput(timer), 0);
    s2d.add(player, playerLayer);
    echos = [];
    
    dialogue = ui.dialogue;
    dialogue.show("game_start".l(), () -> {}, false, player);
    
    State.camera.setAnchor(0.5, 0.5);
    State.camera.setScale(0.7, 0.7);
    
    step();
  }
  
  public function damageShip(amount:Float) {
    State.hp -= amount;
    // UI
    if (State.hp < 0) {
      player.filter = new DeathFilter();
      shake();
      Res.sound.crash.sfx();
      shakeTime = 3;
    }
  }
  
  var circ:Circle = new Circle(0, 0, 1);
  public function interact(player:Player) {
    circ.x = player.vx;
    circ.y = player.vy;
    for (t in triggers) {
      if (t.isActive) {
        if (t.collider.test(circ, _coll) != null) {
          if (t.isRepaired.indexOf(player) == -1) {
            player.interacting++;
            t.isRepaired.push(player);
          }
        }
      }
    }
  }
  
  public function canInteract(player:Player) {
    circ.x = player.vx;
    circ.y = player.vy;
    for (t in triggers) {
      if (t.isActive) {
        if (t.collider.test(circ, _coll) != null) {
          return true;
        }
      }
    }
    return false;
  }
  
  public function checkRepair(player:Player, t:Trigger) {
    if (player.filter != null || !player.visible) return false;
    circ.x = player.vx;
    circ.y = player.vy;
    return t.collider.test(circ, _coll) != null;
  }
  
  
  override public function onDispose()
  {
    ui.remove();
    super.onDispose();
  }
  
  public function addUpdateable(obj:IUpdateObject) {
    var priority = obj.priority;
    var i = 0;
    final list = updateables;
    final len = list.length;
    while (i < len) {
      var upd = list[i];
      if (upd.priority < priority) break;
      i++;
    }
    list.insert(i, obj);
  }
  
  public inline function removeUpdateable(obj:IUpdateObject) {
    updateables.remove(obj);
  }
  
  override public function preUpdate()
  {
    for (upd in updateables) upd.preUpdate();
  }
  
  static var _coll:ShapeCollision;
  function collide(p:Player) {
    @:privateAccess p.syncPos();
    for (poly in levelCollider) {
      var coll = poly.testCircle(p.collider, _coll, true);
      if (coll != null) {
        p.vx += coll.separationX;
        p.vy += coll.separationY;
      }
    }
    for (d in debris) {
      if (d.isActive) {
        var coll = d.hitbox.testCircle(p.collider, _coll, true);
        if (coll != null) {
          // TODO: Disintegrate if not expected
          p.vx += coll.separationX;
          p.vy += coll.separationY;
        }
      }
    }
  }
  
  static inline var shakeMax:Float = 1;
  var shakeTime:Float;
  var shakeX:Float;
  var shakeY:Float;
  public function shake() {
    shakeTime = shakeMax;
  }
  
  override public function update()
  {
    for (upd in updateables) upd.update();
    root.ysort(playerLayer);
    #if debug
    if (Key.isReleased(Key.SPACE)) {
      finishCycle();
    }
    if (Key.isReleased(Key.R)) {
      destroy();
      haxe.Timer.delay(() -> new GameScene(), 1);
      // new GameScene();
      return;
    }
    if (Key.isReleased(Key.P)) {
      shake();
    }
    #end
    
    var c = State.camera;
    player.syncPos();
    c.x -= shakeX;
    c.y -= shakeY;
    c.x = hxd.Math.clamp(hxd.Math.lerp(c.x, player.absX, hxd.Timer.elapsedTime * 10), camMin, camMax);
    
    if (shakeTime > 0) {
      shakeX = Math.random() * shakeTime * 20;
      shakeY = Math.random() * shakeTime * 20;
      shakeTime -= Timer.elapsedTime;
      c.x += shakeX;
      c.y += shakeY;
    } else shakeX = shakeY = 0;
    // c.y = hxd.Math.lerp(c.y, player.absY, hxd.Timer.elapsedTime * 10);
    
    if (Key.isReleased(Key.U)) {
      var t = new Bitmap(Res.explosion.toTile(), root);
      t.x = 250;
      t.y = 100;
      var s = new ldx.shader.Explosion();
      t.addShader(s);
    }
  }
  
  override public function fixedUpdate()
  {
    var shouldUpdate = true;
    if (State.tea > 0) {
      shouldUpdate = (
        Key.isDown(Key.A) || Key.isDown(Key.D) || Key.isDown(Key.W) || Key.isDown(Key.S) ||
        Key.isDown(Key.LEFT) || Key.isDown(Key.RIGHT) || Key.isDown(Key.UP) || Key.isDown(Key.DOWN) ||
        Key.isDown(Key.E) || Key.isDown(Key.ENTER) || Key.isDown(Key.X)
      );
      if (!shouldUpdate) {
        for (t in triggers) if (t.isRepaired.indexOf(player) != -1) {
          shouldUpdate = true;
          break;
        }
      }
    }
    if (player.filter != null) shouldUpdate = false;
    for (p in echos) p.anim.pause = !shouldUpdate;
    player.anim.pause = !shouldUpdate;
    if (player.interacting == 0 && canInteract(player)) {
      ui.e.visible = true;
    } else ui.e.visible = false;
    if (!shouldUpdate) return; // No tick.
    
    timer.update();
    if (timer.time >= State.surviveTime) {
      Music.jingle(Res.music.jingle_win);
      destroy();
      new CutsceneScene().show(['victory_0', 'victory_1'], [10, 10], () -> new MenuScene());
      // finishCycle();
      return;
    }
    
    for (upd in updateables) upd.fixedUpdate();
    
    collide(player);
    for (e in echos) {
      collide(e);
      if (e.visible && e.filter == null) {
        if (timer.time > State.startInvincibility && player.collider.testCircle(e.collider, _coll) != null) {
          // Res.sound.collide_self.sfx();
          Res.sound.cannon_fire_ed.sfx();
          player.filter = new DeathFilter();
          // finishCycle();
          return;
        }
        var cur = e.replay.current();
        if (cur != null) {
          var dist = hxd.Math.distanceSq(cur.px - e.vx, cur.py - e.vy);
          if (dist > 30*30) e.filter = new DeathFilter();
          else if (dist < 10*10) {
            e.vx = cur.px;
            e.vy = cur.py;
          }
        }
      }
    }
  }
  
  override public function postUpdate()
  {
    for (upd in updateables) upd.postUpdate();
  }
  
  public function finishCycle() {
    var p = new PlayerReplay(timer.replay, player.slot);
    root.add(p, playerLayer);
    echos.push(p);
    var nextSlot = player.slot + 1;
    if (echos.length == spawns.length) {
      var e = echos.shift();
      e.remove();
      nextSlot = e.slot;
    }
    
    player.slot = nextSlot;
    State.hp = State.maxHP;
    State.iteration++;
    if (State.iteration == 1) {
      dialogue.show('death'.l(), () -> {}, false, player);
    } else if (State.iteration == 3) {
      dialogue.show('death4'.l(), () -> {}, false, player);
    }
    Res.sound.respawn.sfx();
    step();
  }
  
  public function oneTimeText(id, ?by:Object) {
    if (State.triggered.exists(id)) {
      State.triggered[id]++;
    }
    State.triggered.set(id, 1);
    var up = false;
    if (by != null) {
      up = by.y < State.s2d.height >> 1;
    }
    dialogue.show(id.l(), () -> {}, up, by == null ? player : by);
  }
  
  // Turn-based
  public function step(amount:Int = 1) {
    for (i in 0...amount) {
      inline processTurn();
      for (upd in updateables) upd.step();
    }
  }
  
  function processTurn() {
    var i = 0;
    while (i < echos.length) {
      var e = echos[i++];
      e.replay.start();
      var pt = spawns[e.slot];
      e.posAt(pt.x, pt.y);
    }
    for (t in triggers) t.reset();
    timer.start();
    ui.cycle();
    var pt = spawns[player.slot];
    player.posAt(pt.x, pt.y);
    State.camera.x = pt.x;
  }
  
}