package core;

import h2d.col.Bounds;
import hxd.Timer;
import h2d.RenderContext;
import h2d.Object;
import h3d.shader.ScreenShader;

class DeathFilter extends h2d.filter.Shader<DeathShader> {
  
  public function new() {
    super(new DeathShader());
    shader.time = 0;
    // autoBounds = false;
    boundsExtend = 10;
    shader.texture = null;
  }
  
  override public function sync(ctx:RenderContext, s:Object)
  {
    shader.time += ctx.elapsedTime;
    super.sync(ctx, s);
  }
  
  override public function getBounds(s:Object, bounds:Bounds)
  {
    s.getBounds(bounds);
    bounds.xMin -= boundsExtend;
    bounds.xMax += boundsExtend;
  }
  
}

class DeathShader extends ScreenShader {
  
  static var SRC = {
    @:import ch3.shader.FXLib;
    @param var time:Float;
    @param var texture:Sampler2D;
    
    function fragment() {
      var uv = distortX(calculatedUV, time, time / 8, 20, 1);
      pixelColor = texture.get(uv);
      pixelColor.rgb *= pixelColor.a;
      // output.color = texture.get(distortX(uv, time, time, 20, 1));
      output.color = pixelColor;
    }
    
  }
  
}