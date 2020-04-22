package game;

import differ.shapes.Shape;
import differ.data.ShapeCollision;
import h2d.RenderContext;
import game.Physics;
import format.tmx.Data;
import h2d.Object;
import differ.shapes.Polygon;

class RouteTrigger extends UpdateObject {
  
  static var checkColl:ShapeCollision = new ShapeCollision();
  public var poly:Shape;
  var contact:Array<PhysicsShape<Any>>;
  var setZ:Null<Int>;
  var lapTrigger:Bool;
  
  public function new(poly:Shape, ?parent:Object, props:TmxProperties)
  {
    super(parent);
    this.poly = poly;
    this.contact = new Array();
    if (props != null)
    {
      if (props.exists("set_z")) setZ = props.getInt("set_z");
      lapTrigger = props.exists("start");
    }
  }
  
  public function check(s:PhysicsShape<Any>)
  {
    if (contact.indexOf(s) == -1)
    {
      enter(s);
    }
  }
  
  override private function sync(ctx:RenderContext)
  {
    super.sync(ctx);
    var i = 0;
    while (i < contact.length)
    {
      if (contact[i].shape.test(poly, checkColl) == null)
      {
        leave(contact[i]);
      }
      else i++;
    }
  }
  
  function leave(s:PhysicsShape<Any>)
  {
    contact.remove(s);
  }
  
  function enter(s:PhysicsShape<Any>)
  {
    contact.push(s);
    if (setZ != null) s.setZ(setZ);
    if (lapTrigger)
    {
      cast(s.owner, Car).laps++;
    }
  }
  
  override private function onAdd()
  {
    super.onAdd();
    Physics.instance.triggers.push(this);
  }
  
  override private function onRemove()
  {
    super.onRemove();
    Physics.instance.triggers.remove(this);
  }
  
}