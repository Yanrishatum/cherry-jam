package engine;

import h3d.scene.Object;
import gasm.core.enums.ComponentType;
import gasm.core.Component;
import gasm.core.Entity;

class HScene extends Component
{
  
  public var s3d(get, never):h3d.scene.Scene;
  private inline function get_s3d():h3d.scene.Scene { return HXP.engine.s3d; }
  
  public static function wrap(scene:HScene, id:String = ""):Entity
  {
    var e:Entity = new Entity(id);
    e.add(scene);
    return e;
  }
  
  public function new(id:String = "")
  {
    wrap(this, id);
    componentType = ComponentType.Actor;
  }
  
  public function begin():Void
  {
    
  }
  
  public function end():Void
  {
    
  }
  
  public function add<E:Entity>(e:E):E
  {
    owner.addChild(e);
    return e;
  }
  
  public function remove<E:Entity>(e:E):E
  {
    owner.removeChild(e);
    return e;
  }
  
}