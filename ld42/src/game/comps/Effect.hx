package game.comps;

import h3d.Vector;
import engine.S3DComponent;
import hxd.res.Model;
import engine.HXP;
import engine.HComp;

class Effect extends HComp
{
  private var model:Model;
  private var at:Vector;
  private var scale:Float;
  
  public function new(model:Model, at:Vector, scale:Float = 1)
  {
    super();
    this.at = at;
    this.model = model;
    this.scale = scale;
    
    HXP.wrap(this);
  }
  
  private var mesh:S3DComponent;
  
  override public function setup()
  {
    
    var obj = HXP.modelCache.loadModel(model);
    obj.playAnimation(HXP.modelCache.loadAnimation(model));
    obj.setPosition(at.x, at.y, at.z);
    obj.currentAnimation.onAnimEnd = destroy;
    obj.currentAnimation.speed = scale;
    obj.currentAnimation.loop = false;
    obj.rotate(Math.PI*.5, 0, 0);
    for (m in obj.getMaterials())
    {
      m.mainPass.enableLights = false;
      m.shadows = false;
    }
    owner.add(mesh = new S3DComponent(obj));
    if (HXP.engine.scene != null) HXP.engine.scene.add(owner);
  }
  
  private function destroy():Void
  {
    if (scale != 1 && !BattleScene.instance.vn.shown) BattleScene.instance.updateAtb = true;
    owner.removeChild(owner);
    owner.dispose();
  }
}