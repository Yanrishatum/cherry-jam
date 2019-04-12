package engine;

import gasm.heaps.HeapsContext;

class HPEngine extends HeapsContext
{
  
  private var s3dRender:S3DRenderer;
  
  private var _switchScene:HScene;
  private var _scene:HScene;
  
  public var scene(get, set):HScene;
  private inline function get_scene():HScene { return _scene; }
  private function set_scene(v:HScene):HScene
  {
    if (v == _scene) return v;
    _switchScene = v;
    return _scene;
  }
  
  public function new()
  {
    HXP.engine = this;
    super(null, null, null, null);
  }
  
  override function init()
  {
    s3dRender = new S3DRenderer(s3d);
    super.init();
    systems.push(s3dRender);
    HXP.init();
    scene = new HScene();
  }
  
  override function update(dt:Float)
  {
    if (_switchScene != null)
    {
      if (_scene != null)
      {
        _scene.end();
        baseEntity.removeChild(_scene.owner);
      }
      _scene = _switchScene;
      _switchScene = null;
      baseEntity.addChild(_scene.owner);
      _scene.begin();
    }
    HXP.startUpdate(dt);
    super.update(dt);
    HXP.endUpdate();
  }
  
}