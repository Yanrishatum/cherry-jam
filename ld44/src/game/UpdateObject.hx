package game;

import h2d.Object;

class UpdateObject extends Object implements IUpdateObject {
  
  override private function onAdd()
  {
    Main.updateList.push(this);
    super.onAdd();
  }
  
  override private function onRemove()
  {
    Main.updateList.remove(this);
    super.onRemove();
  }
  
  public function update():Void
  {
    
  }
  
}

interface IUpdateObject {
  
  public function update():Void;
  
}