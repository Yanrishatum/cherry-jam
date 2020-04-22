package util;

import hxsl.Shader;

class ShadowShader extends Shader {
  
  static var SRC = {
    @:import h3d.shader.Base2d;
    @param var color:Float;
    
    // var outputPosition:Vec4;
    // var textureColor:Vec4;
    
    function vertex()
    {
      absolutePosition.xy = absolutePosition.xy + vec2(-8, 8);
    }
    
    function fragment()
    {
      textureColor = vec4(color, color, color, textureColor.a);
    }
    
  }
  
}