package ld45;

import h3d.impl.RendererFX;
import hxsl.Shader;
import h3d.shader.BaseMesh;

class FogShader extends Shader {
  
  static var SRC = {
    
    @:import h3d.shader.BaseMesh;
    
    var fogDist : Float;
    
    @param var fogColor:Vec4;
    @param var fogDensity:Float = 0.005;
    
    function vertex()
    {
      fogDist = clamp(length(transformedPosition - camera.position)*fogDensity, 0.0, 1.0);
    }
    
    function fragment()
    {
      var factor = (1.0 / exp(fogDist*fogDist));
      // var factor = clamp(1.0 / exp(depth * fogDensity), 0.0, 1.0);
      pixelColor = mix(fogColor, pixelColor, factor);
      // pixelColor = vec4(fogDist, fogDist, fogDist, pixelColor.a);
    }
    
  }
  
}