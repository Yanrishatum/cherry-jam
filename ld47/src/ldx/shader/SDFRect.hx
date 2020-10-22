package ldx.shader;

class SDFRect extends hxsl.Shader {
  
  static var SRC = {
    
    @param var radius:Float = 0.;
    
    var textureColor:Vec4;
    var calculatedUV:Vec2;
    
    function fragment() {
      var center = (calculatedUV - 0.5); // -1..1
      var d0 = abs(center) - 0.5 + radius;
      var len = length(max(d0, 0)) + min(max(d0.x, d0.y), 0) - radius;
      var deriv = fwidth(len);
      textureColor.a *= smoothstep(0, deriv, -len);
    }
    
  }
  
}