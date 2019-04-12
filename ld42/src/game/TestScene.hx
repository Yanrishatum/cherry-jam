package game;

import h3d.mat.Data;
import engine.HXP;
import gasm.core.Entity;
import h3d.scene.Object;
import hxd.Res;
import engine.HScene;
import hxd.fmt.hmd.Library;
import engine.S3DComponent;
import engine.shaders.PlayStationShader;

class TestScene extends HScene
{
  
  public function new()
  {
    super();
  }
  
  override public function begin()
  {
    super.begin();
    /*
    var obj:Object = HXP.modelCache.loadModel(hxd.Res.rigtest2);
    var ent:Entity = new Entity();
    ent.add(new S3DComponent(obj));
    add(ent);
    var anim = HXP.modelCache.loadAnimation(Res.rigtest2);
    @:privateAccess anim.frameCount--;
    obj.playAnimation(anim);
    obj.scale(0.025);
    // obj.rotate(0, Math.PI*.5, -Math.PI*.5);
    // adds a directional light to the scene
    var light = new h3d.scene.DirLight(new h3d.Vector(0.5, 0.5, -0.5), s3d);
    light.enableSpecular = true;

    // set the ambient light to 30%
    s3d.lightSystem.ambientLight.set(0.3, 0.3, 0.3);
    
    // activate lights on boss cubes
    for (mat in obj.getMaterials())
    {
      mat.mainPass.enableLights = true;
      mat.shadows = true;
      mat.castShadows = true;
      mat.receiveShadows = true;
      
      if (mat.texture != null)
      {
        mat.texture.filter = Filter.Nearest;
      }
      mat.mainPass.addShader(new PlayStationShader());
    }
    
    s3d.camera.pos.set( -0, -5, 3);
		s3d.camera.target.z += .5;
    new h3d.scene.CameraController(s3d).loadFromCamera();
    */
    // obj.getMaterials()[0].mainPass.enableLights = true;
  }
  
  override public function update(delta:Float)
  {
    super.update(delta);
    
    // var time:Float = HXP.runtime * .01;
    // var dist = 400;
    
    // s3d.camera.pos.set(dist, dist, 0);
    // s3d.camera.pos.set(Math.cos(time) * dist, Math.sin(time) * dist, dist * 0.7 * Math.sin(time));
  }
  
}