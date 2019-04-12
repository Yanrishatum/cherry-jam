package engine.shaders;

class PlayStationShader extends hxsl.Shader
{
  
  
  static var SRC = {
    
    @:import h3d.shader.BaseMesh;
    
    @param var PREC:Float = 128; // 64
    
    function vertex()
    {
      var localPrec:Float = PREC / (projectedPosition.w);
      var temp = projectedPosition.x * localPrec;
      projectedPosition.x = (fract(temp) > .5 ? ceil(temp) : floor(temp)) / localPrec;
      temp = projectedPosition.y * localPrec;
      projectedPosition.y = (fract(temp) > .5 ? ceil(temp) : floor(temp)) / localPrec;
    }
    
  }
  
  public function new(prec:Float = 128)
  {
    super();
    this.PREC = prec;
  }
  
}