package ldx.shader;

class SDFCircle extends hxsl.Shader {
  static var SRC = {
    
    @var var calculatedUV:Vec2;
    @const var isHollow:Bool = false;
    @const var isPie:Bool = false;
    
    @param var width:Float = 0.15;
    @param var pieStart:Float = 0;
    @param var pieLength:Float = 3.14;
    
    var textureColor:Vec4;
    
    function fragment() {
      
      var centered = calculatedUV -.5;
      var len = length(centered) * 2;
      var deriv = fwidth(len);
      
      if (isHollow) {
        var middle = 1. - width / 2.;
        if (len > middle)
          textureColor.a = 1 - smoothstep(1 - deriv, 1 + deriv, len);
        else 
          textureColor.a = smoothstep(1 - width - deriv, 1 - width + deriv, len);
      } else {
        textureColor.a = 1 - smoothstep(1 - deriv, 1 + deriv, len);
      }
      if (isPie) {
        var angle = atan(centered.y, centered.x);
        var pi = 3.141592653589793;
        var pi2 = 6.283185307179586;
        var start:Float = (angle - pieStart + pi2) % pi2;
        var inRange:Float;
        if (pieLength > 0) {
          inRange = start >= 0 && start < pieLength ? 1 : 0;
        } else {
          var len = pi2 + pieLength;
          inRange = start >= 0 && start < len ? 0 : 1;
        }
        // deriv = fwidth(inRange);
        textureColor.a *= inRange;//smoothstep(- deriv, deriv, inRange);
      }
      
      
    }
  }
}