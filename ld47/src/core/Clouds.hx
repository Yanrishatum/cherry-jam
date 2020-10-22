package core;

import hxd.Res;
import h2d.RenderContext;
import h2d.Tile;
import h2d.Bitmap;
import hxd.Perlin;
import hxd.Pixels;
import h3d.mat.Texture;
import h2d.Object;

class Clouds extends Object {
  
  var shader:CloudShader;
  
  public function new(?parent) {
    super();
    var b = new Bitmap(Res.bg.toTile().center(), this);
    // var b = new Bitmap(Tile.fromTexture(cloud).center(), this);
    b.tileWrap = true;
    shader = new CloudShader();
    shader.vtime = 0;
    b.addShader(shader);
  }
  
  override function sync(ctx:RenderContext)
  {
    scaleX = 1 / State.camera.scaleX;
    scaleY = 1 / State.camera.scaleY;
    x = State.camera.x;
    y = State.camera.y;
    shader.vtime = hxd.Math.lerp(shader.vtime, State.game.timer.time, 0.1);
    super.sync(ctx);
  }
  
}

class CloudShader extends hxsl.Shader {
  
  static var SRC = {
    
    // @:import h3d.shader.Base2d;
    
    // @global var time:Float;
    @param var vtime:Float;
    
    var calculatedUV:Vec2;
    var textureColor:Vec4;
    
    function __init__() {
    }
    
    function fragment() {
      calculatedUV += vec2(vtime / 3, 0);
      // var t = time / 2;
      // calculatedUV = vec2(calculatedUV.x + time, calculatedUV.y);
      // textureColor.a = textureColor.r * textureColor.g * textureColor.b;
      // textureColor.rgb = vec3(1);
      // var col = pixelColor.r;
      // pixelColor.rgb = vec3(col);
    }
    
  }
  
}