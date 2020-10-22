package ldx.shader;

import hxd.Pixels;
import hxd.Timer;
import h3d.mat.Texture;

class Explosion extends hxsl.Shader {
  
  static var SRC = {
    
    @global var time:Float;
    
    @param var noise:Sampler2D;
    @param var start:Float;
    @param var duration:Float;
    
    var textureColor:Vec4;
    @var var calculatedUV:Vec2;
    
    function fragment() {
      var dt = sign(((time - start + length((calculatedUV - 0.5)) / 2) / duration) - noise.get(calculatedUV).r);
      textureColor.a *= 1 - clamp(dt, 0, 1);
    }
    
  }
  
  static var noiseTex:Texture;
  
  public static function generate() {
    if (noiseTex == null) {
      var p = new hxd.Perlin();
      p.normalize = true;
      var pix = Pixels.alloc(512, 512, RGBA);
      final seed = 123234;
      for (y in 0...512) {
        for (x in 0...512) {
          var v = Std.int((p.perlin(seed, x / 128, y / 128, 3) / 2 + 0.5) * 0xff);
          pix.setPixel(x, y, 0xff000000 | v | (v << 8) | (v << 16));
        }
      }
      noiseTex = Texture.fromPixels(pix);
      pix.dispose();
      noiseTex.wrap = Repeat;
    }
  }
  
  public function new(dur:Float = 1) {
    super();
    generate();
    noise = noiseTex;
    start = State.s2d.renderer.time;
    duration = dur;
  }
  
}