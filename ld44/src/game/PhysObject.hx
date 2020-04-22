package game;

import util.DebugDisplay;
import h2d.Object;
import game.Physics;

class PhysObject<T> extends UpdateObject {
  
  public var shape:PhysicsShape<T>;
  
  public function new(shape:PhysicsShape<T>, ?parent:Object)
  {
    this.shape = shape;
    super(parent);
  }
  
  override  private function onAdd()
  {
    Physics.addDynamic(shape);
    super.onAdd();
  }
  
  override private function onRemove()
  {
    Physics.removeDynamic(shape);
    super.onRemove();
  }
  
  override public function update()
  {
    inline syncShape();
    super.update();
  }
  
  public function syncShape()
  {
    this.x = shape.shape.x;
    this.y = shape.shape.y;
    this.rotation = hxd.Math.degToRad(shape.shape.rotation);
  }
  
}