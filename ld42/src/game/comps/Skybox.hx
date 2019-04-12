package game.comps;

import hxd.BitmapData;
import hxd.Res;
import engine.HXP;
import engine.S3DComponent;
import engine.HComp;

class Skybox extends HComp
{
  
  public function new()
  {
    super();
    HXP.wrap(this, "skybox");
  }
  
  override public function setup()
  {
    super.setup();
    
    var btm = Res.skybox2.getPixels();
    var w:Int = Math.ceil(btm.width / 3);
    var h:Int = Math.ceil(btm.height / 3);
    var skyTexture = new h3d.mat.Texture(w, h, [Cube, MipMapped]);
    var box = hxd.Pixels.alloc(w, h, h3d.mat.Texture.nativeFormat);
    inline function store(x:Int, y:Int, layer:Int)
    {
      box.blit(0, 0, btm, x * w, y * h, w, h);
      skyTexture.uploadPixels(box, 0, layer);
    }
    
    // store(1, 1, 0); // FRONT
    // store(3, 1, 1); // BACK
    // store(1, 0, 2); // TOP
    // store(1, 2, 3); // BOTTOM
    // store(0, 1, 4); // LEFT
    // store(2, 1, 5); // RIGHT
    /*
    0	GL_TEXTURE_CUBE_MAP_POSITIVE_X
    1	GL_TEXTURE_CUBE_MAP_NEGATIVE_X
    2	GL_TEXTURE_CUBE_MAP_POSITIVE_Y
    3	GL_TEXTURE_CUBE_MAP_NEGATIVE_Y
    4	GL_TEXTURE_CUBE_MAP_POSITIVE_Z
    5	GL_TEXTURE_CUBE_MAP_NEGATIVE_Z
    */
    
    // // Z-up
    // store(2, 1, 0); // RIGHT
    // store(0, 1, 1); // LEFT
    // store(1, 1, 2); // TOP : FRONT
    // store(3, 1, 3); // BOTTOM : BACK
    // store(1, 0, 4); // FRONT : TOP
    // store(1, 2, 5); // BACK : BOTTOM
    
    // Y-up
    store(2, 1, 0); // RIGHT
    store(0, 1, 1); // LEFT
    store(1, 0, 2); // TOP
    store(1, 2, 3); // BOTTOM
    store(1, 1, 4); // FRONT
    store(0, 0, 5); // BACK
    
    // var bmp = hxd.Pixels.alloc(skyTexture.width, skyTexture.height, h3d.mat.Texture.nativeFormat);
    // for( i in 0...6 ) {
    //   for( x in 0...128 )
    //     for( y in 0...128 )
    //       bmp.setPixel(x,y, 0x99D9EA);
    //   skyTexture.uploadPixels(bmp, 0, i);
    // }
    skyTexture.mipMap = Linear;

    var sky = new h3d.prim.Sphere(30, 128, 128);
    sky.addNormals();
    var skyMesh = new h3d.scene.Mesh(sky);
    skyMesh.scale(100);
    skyMesh.material.mainPass.culling = Front;
    skyMesh.material.shadows = false;
    skyMesh.material.mainPass.enableLights = false;
    var cube = new h3d.shader.CubeMap(skyTexture);
    cube.reflection = false;
    skyMesh.material.mainPass.addShader(cube);
    skyMesh.rotate(0, 0, Math.PI);
    
    owner.add(new S3DComponent(skyMesh));
  }
  
}