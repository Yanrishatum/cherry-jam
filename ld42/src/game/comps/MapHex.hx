package game.comps;
import hxd.snd.Channel;
import hxd.Key;
import msignal.Signal;
import h3d.mat.Data;
import h3d.mat.BlendMode;
import hxd.Event;
import h3d.scene.Interactive;
import hxd.Timer;
import h3d.shader.BaseMesh;
import engine.shaders.PlayStationShader;
import hxd.Res;
import h3d.scene.Object;
import engine.HXP;
import engine.S3DComponent;
import game.HexType;
import engine.HComp;

class MapHex extends HComp
{
  
  public static var hover:MapHex;
  public static var hoverDir:Int;
  
  public static var onHover:Signal2<MapHex, Int> = new Signal2();
  public static var onOut:Signal1<MapHex> = new Signal1();
  public static var onClick:Signal2<MapHex, Int> = new Signal2();
  
  public var type:HexType;
  public var x:Int;
  public var y:Int;
  
  private var mesh:S3DComponent;
  private var last:Object;
  
  private var shake:Float;
  public var destroyed:Bool;
  private static inline var DESTROY_TIME:Float = 3.7;
  
  public var interact:Interactive;
  
  public function new(x:Int, y:Int)
  {
    super();
    this.x = x;
    this.y = y;
    type = HexType.Plains;
    HXP.wrap(this);
  }
  
  public static inline var TILE_WIDTH:Float = 22.5;// - .57;
  public static inline var TILE_HEIGHT:Float = 19.5;// - .55;
  
  override public function setup()
  {
    owner.add(mesh = new S3DComponent(interact = new Interactive(HXP.loadCollider(Res.tile))));
    interact.onMove = onInteractMove;
    interact.onOut = onInteractOut;
    interact.onClick = onInteractClick;
    var stagger:Float = (y % 2) * (TILE_WIDTH / 2);
    mesh.obj.setPosition(x * TILE_WIDTH + stagger, y * TILE_HEIGHT, 0);
    mesh.obj.rotate(0, 0, Math.PI * .5);
    var r:Array<HexType> = HexType.createAll();
    for (m in mesh.obj.getMaterials())
    {
      m.mainPass.culling = Face.Back;
    }
    // setType(type);
  }
  
  private static var piquart:Float = Math.PI * .3;
  private static var piquart2:Float = Math.PI - piquart;
  
  private function onInteractMove(e:Event)
  {
    if (destroyed) return;
    hover = this;
    var angle:Float = Math.atan2(e.relY, e.relX);
    if (angle < 0) // right
    {
      if (angle > -piquart) hoverDir = 1;
      else if (angle > -piquart2) hoverDir = 0;
      else hoverDir = 5;
    }
    else 
    {
      if (angle < piquart) hoverDir = 2;
      else if (angle < piquart2) hoverDir = 3;
      else hoverDir = 4;
    }
    // HexOverlay.cursor.setPos(this, hoverDir);
    onHover.dispatch(this, hoverDir);
    // BattleScene.text.text = 'DIR: ${hoverDir} rx: ${e.relX} ry: ${e.relY} rz: ${e.relZ}';
  }
  
  private function onInteractClick(e:Event):Void
  {
    if (e.button == Key.MOUSE_LEFT)
      onClick.dispatch(this, hoverDir);
    // destroy();
  }
  
  private function onInteractOut(e:Event)
  {
    if (hover == this)
    {
      hover = null;
      // HexOverlay.cursor.hide();
      onOut.dispatch(this);
    } 
  }
  
  override public function update(delta:Float)
  {
    
    if (shake > 0)
    {
      shake -= HXP.elapsed;
      var c:Object = mesh.obj.getChildAt(0);
      if (shake > 0)
      {
        c.setPosition(Math.random() * 2 - 1, Math.random() * 2 - 1, Math.random() * 2 - 1);
      }
      else
      {
        c.setPosition(0, 0, 0);
        shake = 0;
      }
    }
    if (destroyed)
    {
      if (shake == 0)
      {
        mesh.obj.visible = false;
      }
      else
      {
        mesh.obj.z -= HXP.elapsed * 4.5;
        for (m in mesh.obj.getMaterials())
        {
          var s:BaseMesh = m.mainPass.getShader(BaseMesh);
          if (s != null)
          {
            var f:Float = (shake) / DESTROY_TIME;
            // s.color.set(s.color.r, s.color.g, s.color.b, f);
            s.color.set(f, f, f, f);
          }
        }
      }
    }
    else 
    {
      if (type == Water)
      {
        mesh.obj.z = Math.sin(2*Timer.lastTimeStamp + (this.x + this.y)) * 1.5 + 1;
      }
    }
    super.update(delta);
  }
  
  public function swap(to:HexType):Void
  {
    setType(to);
  }
  
  private static var sfx:Channel;
  
  public function destroy():Void
  {
    if (!destroyed)
    {
      if (hover == this) onInteractOut(null);
      shake = DESTROY_TIME + .3;
      destroyed = true;
      if (sfx != null && sfx.position < sfx.duration) sfx.position = 0;
      else sfx = Res.sfx.tile_destroyed.play(false, .1, Main.sfxChannel);
      for (m in mesh.obj.getMaterials())
      {
        m.mainPass.setBlendMode(BlendMode.AlphaAdd);
        m.mainPass.setPassName("alpha");
      }
    }
  }
  
  public function setType(type:HexType):Void
  {
    this.type = type;
    getMesh();
  }
  
  private function getMesh():Object
  {
    var obj:Object = null;
    var z:Float = Math.random() * 4;
    
    switch(type)
    {
      case Forest:
        obj = HXP.modelCache.loadModel(Res.tile_forest_1);
        // color(0, 1, .5);
      case Water:
        obj = HXP.modelCache.loadModel(Res.tile_ocean);
        // color(0, 0, 1);
        z = 0;
      case Plains:
        obj = HXP.modelCache.loadModel(Res.tile_plains_1);
        // color(0, 1, 0);
      case Mountains:
        obj = HXP.modelCache.loadModel(Res.tile_mountain);
        // color(0.6, .6, .6);
        z += 2;
      case Wastelands:
        obj = HXP.modelCache.loadModel(Res.tile_wasteland);
        // color(239/0xff, 228/0xff, 176/0xff);
    }
    if (obj != null)
    {
      // for (m in obj.getMaterials())
      // {
      //   m.mainPass.addShader(new PlayStationShader());
      // }
      if (Math.random() > .5)
        obj.rotate(0, 0, Math.PI);
      mesh.obj.z = z;
      if (last != null) mesh.obj.removeChild(last);
      mesh.obj.addChild(obj);
      last = obj;
    }
    return null;
  }
  
  
  
}