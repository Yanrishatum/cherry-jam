package core;

import hxd.Key;
import h2d.ScaleGrid;
import h2d.filter.Glow;
import ldx.shader.Explosion;
import hxd.Res;
import ldx.Updateable;
import h2d.Graphics;
import hxd.Timer;
import h2d.Text;
import h2d.Tile;
import h2d.Bitmap;
import differ.shapes.Polygon;
import format.tmx.Data;
import h2d.Object;
import differ.shapes.Shape;

class Trigger extends Updateable {
  
  public var collider:Polygon;
  public var appearAt:Float;
  var hpStart:Float;
  var decay:Float;
  var damage:Float;
  var recoverTime:Float;
  var once:Bool;
  var decayAfterRepair:Bool;
  
  public var canDecay:Bool;
  public var isRepaired:Array<Player>;
  public var isActive:Bool;
  public var hp:Float;
  
  var state:TriggerState;
  
  public function new(ref:TmxObject, ?parent) {
    super(parent);
    this.name = ref.name;
    this.x = ref.x;
    this.y = ref.y;
    var props = ref.properties;
    inline function getF(n, def:Float) {
      var v = props.getFloat(n);
      if (Math.isNaN(v)) return def;
      else return v;
    }
    
    this.appearAt = getF("appear_at", 0);
    this.hpStart = this.hp = getF("start_at", 50);
    var frame = 1 / Timer.wantedFPS;
    this.damage = getF("damage", 1) * frame;
    this.decay = getF("decay", 10) * frame;
    this.recoverTime = (100 / getF("recover_time", 5)) / Timer.wantedFPS;
    this.once = ref.type == "single";
    this.decayAfterRepair = ref.type != "hole";
    
    switch (ref.objectType) {
      case OTRectangle:
        collider = Polygon.rectangle(x, y, ref.width, ref.height, false);
      case OTPolygon(points):
        collider = new Polygon(x, y, [for (pt in points) new differ.math.Vector(pt.x, pt.y)]);
      default: throw "TODO Trigger shape other than rect";
    }
    
    state = new TriggerState(this);
    
    if (ref.type == "hole") {
      var bb = collider.bounds();
      var b = new Bitmap(Res.hole.toTile().center(), this);
      b.setPosition(Math.round((bb.xMax - bb.yMin) / 2), Math.round((bb.yMax - bb.yMin) / 2));
      b.scale(0.5);
      makeOutline();
    } else if (ref.type != "debris") {
      makeOutline();
    } else if (name == "tea") {
      decayAfterRepair = false;
      makeOutline();
    }
    
    reset();
  }
  
  function makeOutline() {
    // var b = collider.bounds();
    // var g = new ScaleGrid(Utils.allocSDFTile(128, 128, 0x134ad8, 0.2), 32, 32, this);
    // g.x = b.xMin;
    // g.y = b.yMin;
    // g.width = b.width;
    // g.height = b.height;
    // var rct = new ldx.shader.SDFRect();
    // rct.radius = 8 / 128;
    // g.addShader(rct);
    
    var g = new Graphics(this);
    var g2 = new Graphics(this);
    g.beginFill(0xffffff, 1);
    g2.beginFill(0x7ca2ff, 0.3);
    for (pt in collider.vertices) {
      g.lineTo(pt.x, pt.y);
      g2.lineTo(pt.x, pt.y);
    }
    
    var glow = new Glow(0x776e8e, 1, 50, 1, 1, true);
    // var glow = new Glow(0xff0000, 1, 50, 1, 1, true);
    glow.knockout = true;
    g.filter = glow;
    // g.alpha = 0.7;
    // g.blendMode = Screen;
  }
  
  public function reset() {
    isActive = appearAt == 0;
    canDecay = name != 'tea';
    hp = isActive ? hpStart : -1;
    isRepaired = [];
    if (name == "tea" && State.iteration > 0) {
      hp = 10;
      isActive = false;
    }
    visible = isActive;
    if (isActive) onAppear();
  }
  
  override public function fixedUpdate()
  {
    if (isActive) {
      var i = 0;
      while (i < isRepaired.length) {
        var p = isRepaired[i];
        if (!State.game.checkRepair(p, this)) {
          isRepaired.remove(p);
          p.interacting--;
        } else i++;
      }
      if (isRepaired.length > 0) {
        hp += recoverTime * isRepaired.length;
        if (hp >= 100) {
          hp = 100;
          if (!decayAfterRepair || once) {
            isActive = false;
            canDecay = false;
            visible = false;
            for (p in isRepaired) p.interacting--;
            isRepaired = [];
            onDisappear(true);
          } else {
            isRepaired = isRepaired.filter((p) -> {
              var f = p.provider.current();
              if (f != null && (f.isDown(Key.E) || f.isDown(Key.X) || f.isDown(Key.ENTER))) {
                return true;
              } else {
                p.interacting--;
                return false;
              }
            });
          }
          var id = this.name + "_done";
          if (id.hasLocaleKey()) {
            State.game.oneTimeText(id, this);
          }
        }
      } else if (canDecay) {
        var old = hp;
        hp -= decay;
        if (hp < 33 && old >= 33) Res.sound.alarm_small_ed.sfx(R.alarmGroup);
        else if (hp <= 0 && old > 0) Res.sound.alarm_big_ed.sfx(R.alarmGroup);
        
        if (hp <= 0) {
          hp = 0;
          if (damage != 0) State.game.damageShip(damage);
          if (once) {
            isActive = false;
            for (p in isRepaired) p.interacting--;
            isRepaired = [];
            visible = false;
            onDisappear(false);
            State.game.shake();
          }
        }
      }
    } else { // not appeared yet
      if (hp == -1 && State.game.timer.time >= appearAt) {
        isActive = true;
        visible = true;
        onAppear();
        hp = hpStart;
      }
    }
    super.fixedUpdate();
  }
  function onAppear() {
    if (name == "hole") {
      var e = new Bitmap(Res.explosion.toTile().center(), this);
      e.setPosition(children[children.length - 1].x, children[children.length - 1].y);
      var s = new Explosion(.5);
      e.addShader(s);
      haxe.Timer.delay(() -> e.remove(), Std.int(s.duration * 1000) + 50);
      Res.sound.hull_breakdown_ed.sfx();
    } else if (name == "lightning_rod") {
      Res.sound.thunder_roll.sfx();
    } else if (name == "cannon") {
      Res.sound.MONSTER_BEFORE_ATTACK_ed.sfx();
    } else if (name == "wheel") {
      Res.sound.island_approach.sfx();
    }
    var id = this.name + "_appear";
    if (id.hasLocaleKey()) {
      State.game.oneTimeText(id, this);
    }
  }
  function onDisappear(gotFixed:Bool) {
    if (name == "debris" || name == "hole") {
      if (gotFixed) Res.sound.hull_repair_ed.relSFX(this);
    } else if (name == "gunpowder") {
      if (!gotFixed) Res.sound.blast.sfx();
    } else if (name == "lightning_rod") {
      if (gotFixed) Res.sound.electric_repair_ed.relSFX(this);
      else Res.sound.thunder_hit.sfx();
    } else if (name == "cannon") {
      if (gotFixed) Res.sound.MONSTER_ATTACK_ed.relSFX(this);
      else Res.sound.MONSTER_HIT_ed.sfx();
    } else if (name == "wheel") {
      if (gotFixed) Res.sound.island_miss.relSFX(this);
      else Res.sound.crash.sfx();
    } else if (name == 'tea') {
      Res.sound.tea_gentleman.relSFX(this);
    }
  }
}