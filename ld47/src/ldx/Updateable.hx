package ldx;

import h2d.Object;

class Updateable extends Object implements IUpdateObject {
  
  public var priority:Float;
  
  public function new(priority:Float = 1, ?parent) {
    this.priority = priority;
    super(parent);
  }
  
  override function onAdd()
  {
    super.onAdd();
    State.game.addUpdateable(this);
  }
  
  override function onRemove()
  {
    super.onRemove();
    State.game.removeUpdateable(this);
  }
  
  public function preUpdate():Void {
    
  }
  
  public function update():Void {
    
  }
  
  public function fixedUpdate():Void {
    
  }
  
  public function postUpdate():Void {
    
  }
  
  // For turn-based
  public function step() {
    
  }
  
}