package game.comps;

import h3d.mat.BlendMode;
import hxd.Res;
import h3d.scene.Object;
import h3d.shader.BaseMesh;
import structural.Pool;
import h3d.prim.Sphere;
import h3d.scene.Mesh;
import engine.S3DComponent;
import engine.HXP;
import engine.HComp;

class HexOverlay extends HComp
{
  // public static var pool:Pool<HexOverlay> = new Pool(5, 0, HexOverlay.new);
  private static var _cursor:HexOverlay;
  public static var cursor(get, never):HexOverlay;
  private static inline function get_cursor():HexOverlay
  {
    if (_cursor == null)
    {
      _cursor = new HexOverlay();
      HXP.engine.scene.add(_cursor.owner);
    }
    return _cursor;
    
  }
  
  private var mesh:S3DComponent;
  private var tileYes:Object;
  private var tileNo:Object;
  public var x:Int;
  public var y:Int;
  
  private static inline var tileZ:Float = 10;
  private var linkedTile:MapHex;
  
  public function new()
  {
    super();
    HXP.wrap(this);
  }
  
  public function setPos(hex:MapHex, dir:Int):Void
  {
    // setPosOffset(hex, dir);
    setPosXY(hex.x, hex.y);
  }
  
  public function setPosXY(x:Int, y:Int):Void
  {
    if (x < 0 || y < 0 || x >= GridMap.instance.width || y >= GridMap.instance.height)
    {
      invalid();
    }
    this.x = x;
    this.y = y;
    
    var tile:MapHex = GridMap.instance.tile(x, y);
    var z:Float = tileZ;
    if (tile != null)
    {
      z += @:privateAccess tile.mesh.obj.z;
      linkedTile = tile;
    }
    var stagger:Float = Math.abs(y % 2) * (MapHex.TILE_WIDTH / 2);
    mesh.obj.setPosition(x * MapHex.TILE_WIDTH + stagger, y * MapHex.TILE_HEIGHT, z);
  }
  
  public function setPosOffset(hex:MapHex, dir:Int):Void
  {
    var coord = GridMap.moveCoord(hex.x, hex.y, dir);
    setPosXY(coord.x, coord.y);
  }
  
  public function hide():Void
  {
    tileYes.visible = false;
    tileNo.visible = false;
    linkedTile = null;
  }
  
  override public function setup()
  {
    inline function fix(o:Object):Void
    {
      o.rotate(0, 0, Math.PI*.5);
      for (m in o.getMaterials())
      {
        m.mainPass.setBlendMode(BlendMode.AlphaAdd);
        m.mainPass.setPassName("alpha");
        m.mainPass.getShader(BaseMesh).color.a = .5;
        m.castShadows = false;
      }
    }
    
    tileYes = HXP.modelCache.loadModel(Res.tile_select_yes);
    fix(tileYes);
    tileNo = HXP.modelCache.loadModel(Res.tile_select_no);
    fix(tileNo);
    owner.add(mesh = new S3DComponent(new Object()));
    mesh.obj.addChild(tileYes);
    mesh.obj.addChild(tileNo);
    mesh.obj.scaleX = 0.95;
    mesh.obj.scaleY = 0.95;
  }
  
  override public function update(delta:Float)
  {
    if (linkedTile != null)
    {
      mesh.obj.z = tileZ + @:privateAccess linkedTile.mesh.obj.z;
      
    }
  }
  
  public function ok():HexOverlay
  {
    tileYes.visible = true;
    tileNo.visible = false;
    return this;
  }
  
  public function invalid():HexOverlay
  {
    tileYes.visible = false;
    tileNo.visible = true;
    return this;
  }
  
  
}

enum OverlayType
{
  
  Forbidden;
  Selection;
  
}