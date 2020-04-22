package game;

import hxd.Res;
import h2d.Tile;
import differ.data.ShapeCollision;
import hxd.Math;
import game.ai.RaceState;
import haxe.Json;
import owlbt.OwlContext;
import game.ai.AIState;
import h2d.col.Point;
import util.DebugDisplay;
import differ.shapes.Polygon;
import game.Physics;
import hxd.Timer;
import hxd.Direction;
import h2d.Bitmap;
import util.Trail2D;

class Car extends PhysObject<Car>
{
  
  public var isPlayer:Bool;
  public var stats:CarStats;
  public var angle:Float;
  public var carAngle:Float;
  public var velocity:Float;
  var shadow:Bitmap;
  var car:Bitmap;
  var angleOff = -Direction.Up.angle;
  var drifting:Float = 0;
  
  public var trails:Trail2D;
  var trailOffsets:Array<Point>;
  
  // STATE
  public var race:RaceState;
  public var ai:AIState;
  public var node:RoutePoint;
  public var position:Float = 0;
  public var laps:Int = -1;
  public var hpMax:Float;
  public var hp:Float;
  
  public var ramProtection:Bool;
  public var invulnerable:Bool;
  var rammed:Bool;
  var frames:Array<Tile>;
  var frameT:Float = 0;
  var frameI:Int = 0;
  
  public var abilities:Array<Ability>;
  
  public function new(ref:Cars, isPlayer:Bool)
  {
    super(new PhysicsShape(this, Polygon.rectangle(0, 0, 100, 170)));
    shape.onCollision = resolveRam;
    shape.setZ = updateLayer;
    this.isPlayer = isPlayer;
    
    abilities = new Array();
    ai = new AIState(this, OwlContext.parse(Json.parse(hxd.Res.ai.horse.entry.getText()), AIState.resolveNode, AIState.resolveDecorator));
    
    this.stats = new CarStats(ref);
    this.carAngle = this.angle = Direction.Up.angle;
    this.velocity = 0;
    var img = hxd.Res.load(ref.image).toTile().center();
    shadow = Util.makeShadow(img, this);
    car = new Bitmap(img, this);
    trailOffsets = new Array();
    switch(ref.name)
    {
      case emo:
        trails = new Trail2D(0x5a534b, .5, 48);
        trailOffsets = [
          new Point(img.dx + 180, img.dy + 85),
          new Point(img.dx + 126, img.dy + 233),
          new Point(img.dx + 239, img.dy + 233),
        ];
      case rider:
        trails = new Trail2D(0x5a534b, 0.5, 48);
        var sheet = hxd.Res.cars.rider_4pcs_361x361.toTile();
        frames = sheet.split(4);
        for (f in frames) f.setCenterRatio();
      case stroker:
        trails = new Trail2D(0x5a534b, 0.5, 48);
        trailOffsets = [
          new Point(img.dx + 126, img.dy + 85),
          new Point(img.dx + 239, img.dy + 85),
          new Point(img.dx + 126, img.dy + 233),
          new Point(img.dx + 239, img.dy + 233),
        ];
      case booty:
        trails = new Trail2D(0x44392b, 0.5, 48);
        trailOffsets = [
          new Point(img.dx + 180, img.dy + 85),
          new Point(img.dx + 180, img.dy + 233),
        ];
        var sheet = hxd.Res.cars.trap_5pcs_361x361.toTile();
        frames = sheet.split(5);
        for (f in frames) f.setCenterRatio();
        shadow.tile = frames[0];
        car.tile = frames[0];
    }
    hp = hpMax = stats.hpPool;
  }
  
  public function realPos()
  {
    return position + laps * race.length;
  }
  
  function resolveRam(self:PhysicsShape<Car>, other:PhysicsShape<Any>, coll:ShapeCollision)
  {
    var oc:Car = cast(other.owner, Car);
    if (oc != null && !oc.invulnerable && !oc.ramProtection)
    {
      self.shape.x += coll.separationX * .5;
      self.shape.y += coll.separationY * .5;
      other.shape.x -= coll.separationX;
      other.shape.y -= coll.separationY;
      var angle = Math.PI+Math.atan2(coll.separationY, coll.separationX);
      oc.angle = Math.angleLerp(oc.angle, angle, 0.05);
      if (velocity > oc.velocity * 1.4)
      {
        oc.damage(oc.velocity / velocity);
        velocity *= 0.8;
        oc.angle = Math.angleLerp(oc.angle, angle, 0.2);
        oc.velocity *= 1.1;
      }
      // TODO: Ram
    }
    else 
    {
      self.shape.x += coll.separationX;
      self.shape.y += coll.separationY;
    }
    rammed = true;
  }
  
  public function damage(amount:Float)
  {
    if (!invulnerable)
    {
      hp -= amount;
      if (hp < 0) hp = hpMax;
    }
  }
  
  override public function update()
  {
    if (!race.started) return;
    rammed = false;
    if (isPlayer)
    {
      if (LD.drift.down) drifting = 1;
      else if (drifting > 0)
      {
        drifting -= Timer.dt;
        if (drifting < 0) drifting = 0;
      }
      
      if (drifting < 0.9 && LD.forward.down)
      {
        velocity += stats.acceleration * Timer.dt;
        if (velocity > stats.maxSpeed) velocity = hxd.Math.lerp(velocity, stats.maxSpeed, .98);
      }
      else if (drifting < 0.9 && LD.back.down)
      {
        velocity -= stats.deceleration * Timer.dt;
      }
      else 
      {
        if (velocity > 0)
        {
          velocity -= stats.drag * Timer.dt;
          if (velocity < 0) velocity = 0;
        }
        else if (velocity != 0)
        {
          velocity += stats.drag * Timer.dt;
          if (velocity > 0) velocity = 0;
        }
      }
      var turn = if (LD.left.down)
        LD.right.down ? 0 : -1;
      else 
        LD.right.down ? 1 : 0;
      
      if (turn != 0)
      {
        setAngle(carAngle + (stats.handling + stats.handlingRange * (velocity == 0 ? 1 : (1 - velocity / stats.maxSpeed)) + (drifting != 0 ? stats.driftBonus : 0)) * Timer.dt * turn);
      }
      
      if (LD.ability_a.pressed)
        abilities[0].activate(this);
      if (LD.ability_b.pressed)
        abilities[1].activate(this);
      if (LD.ability_c.pressed)
        abilities[2].activate(this);
      if (LD.ability_d.pressed)
        abilities[3].activate(this);
    }
    else 
    {
      if (ai.engine != 0)
      {
        var speed = ai.engine * stats.maxSpeed;
        var mult = ai.engine > velocity ? stats.acceleration : stats.deceleration;
        velocity = hxd.Math.lerp(velocity, speed, (mult / stats.maxSpeed) * Timer.dt);
      }
      if (ai.steer == 0)
      {
        if (drifting > 0)
        {
          drifting -= Timer.dt;
          if (drifting < 0) drifting = 0;
        }
        if (node != null)
        {
          var lookahead = (node.distance + 2000) % race.length;
          var n = node.next.next;
          while (n.distance + n.length < lookahead)
          {
            n = n.next;
          }
          var n = n.vec;
          // var n = node.next.next.vec;
          var angle = Math.atan2(n.y - y, n.x - x);
          var diff = Math.angle(carAngle - angle);
          if (Math.abs(diff) > 0.6) {
            drifting = 1;
          }
          setAngle(hxd.Math.angleMove(carAngle, angle, (stats.handling + stats.handlingRange * (velocity == 0 ? 1 : (1 - velocity / stats.maxSpeed)) + (drifting != 0 ? stats.driftBonus : 0)) * Timer.dt));
        }
        // (stats.handling + stats.handlingRange * (velocity == 0 ? 1 : (1 - velocity / stats.maxSpeed)) + (drifting != 0 ? stats.driftBonus : 0)) * Timer.dt
        // var targetAngle =
      }
    }
    var travel = shape.move(angle, velocity * Timer.dt);
    if (!rammed && travel < Math.abs(velocity * Timer.dt) - hxd.Math.EPSILON)
    {
      if (velocity < 0)
      {
        velocity += stats.friction * Timer.dt;
      }
      else 
      {
        velocity -= stats.friction * Timer.dt;
      }
    }
    this.angle = hxd.Math.angleLerp(angle, carAngle, drifting != 0 ? 0.02 + (0.08 * (1 - drifting)) : 0.1);
    if (drifting > 0.6)
    {
      syncPos();
      var cos = Math.cos(carAngle + Math.PI * .5);
      var sin = Math.sin(carAngle + Math.PI * .5);
      for (i in 0...trailOffsets.length)
      {
        var k = trailOffsets[i];
        
        trails.add(i, this.x + (k.x * cos + k.y * -sin), this.y + (k.x * sin + k.y * cos), carAngle);
      }
    } else trails.cut();
    
    if (frames != null)
    {
      frameT += Timer.dt;
      var rate = Math.max(0.02, (1 - velocity / Const.SPEED_CONSTANT*1.6) * .4);
      if (rate > Math.EPSILON && velocity > 1)
      while (frameT > rate)
      {
        frameT -= rate;
        frameI++;
        if (frameI == frames.length) frameI = 0;
        car.tile = frames[frameI];
        shadow.tile = frames[frameI];
      }
    }
    
    super.update();
    // DebugDisplay.info('Velocity: ${hxd.Math.fmt(velocity)}\nMaxvel: ${stats.maxSpeed}\nX: ${hxd.Math.fmt(x)}\nY: ${hxd.Math.fmt(y)}', 150);
  }
  
  function updateLayer(z:Int)
  {
    shape.z = z;
    parent.addChildAt(this, 2 + z);
    // var l = cast(parent, Layers);
    // l.add
  }
  
  public inline function setAngle(angle:Float)
  {
    this.carAngle = angle;
    // if (!drifting)
    //   this.angle = angle;
    shape.shape.rotation = hxd.Math.radToDeg(angle + angleOff);
  }
  
  // override  private function sync(ctx:RenderContext)
  // {
  //   super.sync(ctx);
    
  //   DebugDisplay.graphics.lineStyle(4, 0xff);
  //   DebugDisplay.graphics.moveTo(this.absX, this.absY);
  //   if (node != null)
  //   {
  //     var pt = new h2d.col.Point(
  //       node.vec.x * parent.matA + node.vec.y * parent.matC + parent.absX,
  //       node.vec.x * parent.matB + node.vec.y * parent.matD + parent.absY);
  //     // DebugDisplay.info('$pt, $absX, $absY, $x, $y', 10, 400);
  //     DebugDisplay.graphics.lineTo(pt.x, pt.y);
  //     var node = node.next;
  //     var ang = Math.atan2(node.vec.y - this.node.vec.y, node.vec.x - this.node.vec.x);
  //     pt.set(
  //       this.node.vec.x + Math.cos(ang) * (position - this.node.distance),
  //       this.node.vec.y + Math.sin(ang) * (position - this.node.distance));
  //     var pt = new h2d.col.Point(
  //       pt.x * parent.matA + pt.y * parent.matC + parent.absX,
  //       pt.x * parent.matB + pt.y * parent.matD + parent.absY);
  //     DebugDisplay.graphics.moveTo(this.absX, this.absY);
  //     DebugDisplay.graphics.lineTo(pt.x, pt.y);
  //   }
  //   // DebugDisplay.graphics.lineTo(this.absX + Math.cos(angle) * velocity, this.absY + Math.sin(angle) * velocity);
  //   // DebugDisplay.graphics.moveTo(this.absX, this.absY);
  //   // DebugDisplay.graphics.lineTo(this.absX + Math.cos(carAngle) * 100, this.absY + Math.sin(carAngle) * 100);
  // }
  
}