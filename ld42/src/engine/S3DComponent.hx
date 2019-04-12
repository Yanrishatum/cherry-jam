package engine;

import gasm.core.enums.ComponentType;
import h3d.scene.Object;
import h3d.scene.Mesh;
import gasm.core.Component;

class S3DComponent extends Component
{
  
  public var obj:Object;
  
  public function new(obj:Object)
  {
    this.obj = obj;
    this.componentType = ComponentType.Graphics3D;
  }
  
  override public function dispose()
  {
    if (obj.parent != null) obj.remove();
  }
  
}