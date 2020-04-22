package ld45;

import hxd.Key;
import ld45.State;
import hxd.res.Model;
import h3d.shader.Outline;
import h3d.scene.RenderContext;
import h3d.shader.BaseMesh;
import h3d.scene.Object;
import hxd.Timer;
import hxd.Event;
import hxd.Res;
import h3d.scene.Interactive;

class HexTile extends HexObject
{
  public var type:TileType;
  public var inter:Interactive;
  
  public var neighbors:Array<HexTile> = [];
  public var resource:Int;
  public var quest:Int = -1;
  
  var wave:Float = Math.NaN;
  var visual:Object;
  var discovered:Bool;
  
  static inline var BOT_OFFSET:Float = -5;
  
  public var enabled(default, set):Bool;
  inline function set_enabled(v) { inter.cursor = (v ? hxd.Cursor.Button : Default); return enabled = v; }
  
  public var alpha:Float = 0;
  public var icon:TileIcon;
  
  public var edge:EdgeDir;
  
  public function new(?parent, tx:Int, ty:Int, type:TileType)
  {
    super(parent, tx, ty);
    this.type = type;
    var info:TileBalance = Reflect.field(State.config.tiles, type.getName());
    var resourceChange = info.gather.length > 0 ? 0.5 : 0;
    var rotate = true;
    var shiftMargin:Float = 0.1;
    var extra:Object = null;
    var extra_outline:Model = null;
    visual = 
    switch (type)
    {
      case Grass:
        Main.cache.loadModel(Res.models.tile_grass);
      case Forest:
        Main.cache.loadModel(Res.models.tile_forest);
      case Land:
        Main.cache.loadModel(Res.models.tile_land);
      case Mountain:
        Main.cache.loadModel(Res.models.tile_mountain);
      case Ocean:
        resourceChange = 1;
        wave = tx + ty;
        shiftMargin = 0;
        Main.cache.loadModel(Res.models.tile_ocean);
      case Corruption:
        Main.cache.loadModel(Res.models.tile_corrupt);
      case Bridge:
        wave = tx + ty;
        shiftMargin = 0;
        extra = Main.cache.loadModel(Res.models.tile_bridge);
        extra_outline = Res.models.tile_bridge_outline;
        Main.cache.loadModel(Res.models.tile_ocean);
      case House:
        resourceChange = 1;
        extra = Main.cache.loadModel(Res.models.tile_house);
        extra_outline = Res.models.tile_house_outline;
        Main.cache.loadModel(Res.models.tile_grass);
      case Village:
        resourceChange = 1;
        extra = Main.cache.loadModel(Res.models.tile_town);
        extra_outline = (Res.models.tile_town_outline);
        Main.cache.loadModel(Res.models.tile_grass);
      case Tower:
        resourceChange = 1;
        extra = Main.cache.loadModel(Res.models.tile_tower);
        extra_outline = (Res.models.tile_tower_outline);
        Main.cache.loadModel(Res.models.tile_grass);
      case Snow:
        Main.cache.loadModel(Res.models.tile_snow);
      case SnowForest:
        Main.cache.loadModel(Res.models.tile_snow_forest);
      case SnowMountain:
        Main.cache.loadModel(Res.models.tile_snow_mountain);
      case Crater:
        Main.cache.loadModel(Res.models.tile_craters);
      case Volcano:
        Main.cache.loadModel(Res.models.tile_volcano);
      // default:
      //   rotate = false;
      //   Main.cache.loadModel(Res.models.tile_collision);
    }
    if (extra != null)
    {
      if (extra_outline != null) Util.addModelOutline(this, extra_outline);
      // else extra = Util.addOutline(extra);
      addChild(extra);
    }
    if (rotate)
    {
      visual.setRotationAxis(0, 0, 1, (Math.PI*2/6)*Math.ffloor(Math.random() * 6));
    }
    visual.z += (Math.random() * 2 - 1) * shiftMargin;
    addChild(visual);
    resource = Math.random() <= resourceChange ? 0 : -1;
    
    var col = Main.cache.loadModel(Res.models.tile_collision).toMesh();
    inter = new Interactive(col.getCollider());
    inter.onOver = selEvent;
    inter.onOut = selEvent;
    inter.onClick = selEvent;
    inter.enableRightButton = true;
    addChild(inter);
    this.z = BOT_OFFSET;
    enabled = false;
    discovered = false;
    icon = new TileIcon(this);
    icon.show(resource != -1, quest != -1);
    setAlpha();
    for (m in getMaterials())
    {
      m.mainPass.setBlendMode(Alpha);
      m.mainPass.setPassName("alpha");
    }
    // inter.visible = false;
    // new h3d.col.ObjectCollider(Res.models.tile_collision.)
    // inter = new Interactive(this); // TODO: Hexagonal collider
  }
  
  override function onAdd()
  {
    active = false;
    super.onAdd();
  }
  
  public function setAlpha()
  {
    var v = this.z < 0 ? 1 - (-z / -BOT_OFFSET) : 1;
    for (m in getMaterials())
    {
      var mesh = m.mainPass.getShader(BaseMesh);
      if (mesh != null) mesh.color.set(v, v, v, v);
      var out = m.getPass("outline");
      if (out != null)
      {
        var shader = out.getShader(Outline);
        if (shader != null) shader.color.a = v;
      }
    }
  }
  
  function selEvent(e:Event)
  {
    if (discovered)
    {
      if (e.kind == EOver)
      {
        if (pos.equals(GameMap.current.player.pos))
        {
          var t = "Right click to " + Const.CAMP_TIP.substr(0,1).toLowerCase() + Const.CAMP_TIP.substr(1);
          if (!State.ui.camp.enabled) t += Const.CAMP_NOPE;
          GameMap.current.tileInfo.showText(t, this);
        }
        else GameMap.current.tileInfo.show(this);
      }
      else if (e.kind == EOut)
      {
        GameMap.current.tileInfo.hide();
      }
    }
    if (enabled)
    {
      if (e.kind == EOver)
      {
        GameMap.current.selection.show(pos);
      }
      else if (e.kind == EOut)
      {
        GameMap.current.selection.hide();
      }
      else if (e.kind == ERelease)
      {
        if (pos.equals(GameMap.current.player.pos))
        {
          if (e.button == Key.MOUSE_RIGHT && State.ui.camp.visible)
            State.camp();
        }
        else
        {
          GameMap.current.tileInfo.hide();
          GameMap.current.player.goTo(this);
        }
      }
    }
  }
  
  public function check()
  {
    if (!discovered)
    {
      inter.visible = true;
      if (GameMap.current.player.pos.distance(pos) <= State.viewDist)
      {
        discovered = true;
        var t = new RiseTween();
        t.setup(this, 1, 0, 1);
        if (this.edge != None)
        {
          GameMap.current.expand(pos, this.edge);
          edge = None;
        }
      }
    }
    else 
    {
      var dist = GameMap.current.player.pos.distance(pos);
      inter.visible = dist < 12;
      this.visible = dist < 14;
    }
  }
  
  public function resetResource()
  {
    if (type != Ocean)
      resource = -1;
    updateIcon();
  }
  
  public inline function updateIcon()
  {
    icon.show(resource != -1, quest != -1);
  }
  
  override public function update()
  {
    if (!Math.isNaN(wave))
    {
      wave += Timer.elapsedTime;
      visual.z = Math.cos(wave) * 0.5;
    }
    // if (discovered && this.z < 0)
    // {
    //   this.z += Timer.elapsedTime * 6;
    //   if (this.z > 0) this.z = 0;
    //   setAlpha();
    // }
  }
  
  public function isWalkable():Bool
  {
    return type != Ocean && type != Mountain && type != Volcano && type != SnowMountain;
  }
  
}

@:ease
@:tween(alpha = 1)
@:apply({
  target.setAlpha();
})
@:ease(hxd.Ease.backOut)
@:tween(z = 0)
class RiseTween extends yatl.VariableTween<HexTile>
{
  
}

enum EdgeDir
{
  None;
  Left;
  Up;
  Down;
  Right;
  
  TopLeft;
  TopRight;
  BottomLeft;
  BottomRight;
}