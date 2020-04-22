package game;

import h2d.Graphics;
import util.DebugDisplay;
import differ.data.ShapeCollision;
import differ.Collision;
import h2d.Object;
import util.PhysRender;
import differ.shapes.Shape;

class Physics {
  
  public static var instance:Physics = new Physics();
  
  public var statics:Map<Int, Array<Shape>>;
  public var dynamics:Array<PhysicsShape<Any>>;
  public var triggers:Array<RouteTrigger>;
  var render:util.PhysRender;
  public var renderCallbacks:Array<Graphics->Void> = new Array();
  
  public function new()
  {
    statics = new Map();
    dynamics = new Array();
    triggers = new Array();
  }
  
  public static function reset()
  {
    instance.statics = new Map();
    instance.dynamics = new Array();
    instance.triggers = new Array();
  }
  
  public static inline function addStatic(z:Int, s:Shape)
  {
    var arr = instance.statics[z];
    if (arr == null) instance.statics[z] = [s];
    else arr.push(s);
  }
  
  public static inline function removeStatic(z:Int, s:Shape)
  {
    instance.statics[z].remove(s);
  }
  
  public static inline function addDynamic<T>(s:PhysicsShape<T>)
  {
    instance.dynamics.push(cast s);
  }
  
  public static inline function removeDynamic<T>(s:PhysicsShape<T>)
  {
    instance.dynamics.remove(cast s);
  }
  
  public function draw(parent:Object)
  {
    if (render == null) render = new PhysRender(parent);
    if (render.g.parent != parent) parent.addChild(render.g);
    render.clear();
    render.color = 0xff0000;
    for (ss in statics)
    {
      for (s in ss)
        render.drawShape(s);
    }
    render.color = 0xff00;
    for (d in dynamics) render.drawShape(d.shape);
    render.color = 0xff;
    for (t in triggers) render.drawShape(t.poly);
    for (cb in renderCallbacks) cb(render.g);
  }
  
}

@:access(game.Physics)
class PhysicsShape<T>
{
  
  public var owner:T;
  public var z:Int = 0;
  static var coll:ShapeCollision = new ShapeCollision();
  public var shape:Shape;
  
  public var collideDynamics:Bool = true;
  
  public dynamic function onCollision(self:PhysicsShape<T>, other:PhysicsShape<Any>, coll:ShapeCollision)
  {
    shape.x += coll.separationX;
    shape.y += coll.separationY;
  }
  
  public dynamic function setZ(z:Int)
  {
    this.z = z;
  }
  
  public function new(owner:T, s:Shape)
  {
    this.owner = owner;
    this.shape = s;
  }
  
  public function set(x:Float, y:Float)
  {
    shape.x = x;
    shape.y = y;
  }
  
  public inline function getColl()
  {
    return coll;
  }
  
  public function move(angle:Float, distance:Float)
  {
    // TODO: Coll
    var s = shape;
    var dx = Math.cos(angle) * distance;
    var dy = Math.sin(angle) * distance;
    var ox = s.x;
    var oy = s.y;
    s.x += dx;
    s.y += dy;
    var i = Physics.instance;
    var c = coll;
    for (os in i.statics[z])
    {
      if (s.test(os, c) != null)
      {
        s.x += c.separationX;
        s.y += c.separationY;
        // TODO: Accel
      }
    }
    if (collideDynamics)
    for (d in i.dynamics)
    {
      if (d != (untyped this) && d.collideDynamics && d.z == z && s.test(d.shape, c) != null)
      {
        onCollision(this, d, c);
      }
    }
    for (t in i.triggers)
    {
      if (s.test(t.poly, c) != null) t.check(cast this);
    }
    ox = s.x - ox;
    oy = s.y - oy;
    return Math.sqrt(ox * ox + oy * oy);
  }
  
}