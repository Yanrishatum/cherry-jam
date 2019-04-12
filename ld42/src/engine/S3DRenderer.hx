package engine;

import gasm.core.enums.ComponentType;
import gasm.core.enums.SystemType;
import h3d.scene.Scene;
import gasm.core.Component;
import gasm.core.ISystem;
import gasm.core.System;

class S3DRenderer extends System implements ISystem
{
  
  public var s3d:Scene;
  
  public function new(s3d:Scene)
  {
    super();
    this.s3d = s3d;
    this.type = SystemType.RENDERING3D;
    componentFlags.set(ComponentType.Graphics3D);
    // componentFlags.set(ComponentType.Graphics3DModel)
  }
  
  public function update(comp:Component, delta:Float)
  {
    if (!comp.inited)
    {
      comp.init();
      var model:S3DComponent = comp.owner.get(S3DComponent);
      if (comp.owner.parent != null)
      {
        var parent:S3DComponent = comp.owner.parent.get(S3DComponent);
        if (parent != null && parent != comp) parent.obj.addChild(model.obj);
        else s3d.addChild(model.obj);
      }
      else 
      {
        s3d.addChild(model.obj);
      }
      comp.inited = true;
    }
    comp.update(delta);
  }
  
}