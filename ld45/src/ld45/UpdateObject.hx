package ld45;

import h3d.scene.Object;

class UpdateObject extends Object
{
  
  var active:Bool = true;
  
  public function update()
  {
    
  }
  
  public function step()
  {
    
  }
  
  override function onAdd()
  {
    super.onAdd();
    if (active) Main.toAdd.push(this);
  }
  
  override function onRemove()
  {
    super.onRemove();
    if (active)Main.toRemove.push(this);
  }
  
}