package comps;

import h2d.Tile;
import h2d.Object;
import hxd.Res;
import h2d.Bitmap;

class Fog extends Object {
  
  public function new(?parent, fv = 0.6) {
    super(parent);
    function noise(t:Tile, offX:Float, speed:Float) {
      var b = new Bitmap(t, this);
      b.tileWrap = true;
      b.scale(0.5);
      var fade = new AlphaFadeoff();
      b.addShader(fade);
      fade.range.set(fv, 1);
      fade.uvOff = offX;
      b.addShader(new h3d.shader.UVScroll(speed));
      t.setSize(t.width * 4, t.height);
    }
    noise(Res.noise.toTile(), 0, 0.05);
    noise(Res.noise_b.toTile(), 0.3, 0.1);
    alpha = 0.2;
  }
  
}

class AlphaFadeoff extends hxsl.Shader {
  
  static var SRC = {
    
    @var var calculatedUV:Vec2;
    var pixelColor:Vec4;
    @var var origV:Float;
    @param var range:Vec2;
    @param var uvOff:Float;
    
    function vertex() {
      origV = calculatedUV.y;
      calculatedUV.x += uvOff;
    }
    
    function fragment() {
      if (origV < range.x) {
        pixelColor.a *= origV / range.x * .05;
      } else {
        pixelColor.a *= (origV - range.x) / (range.y - range.x) * .895 + 0.05;
      }
    }
  }
  
}