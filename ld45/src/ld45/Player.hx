package ld45;

import h3d.scene.RenderContext;
import hxd.Timer;
import h3d.Quat;
import Util;
import h3d.scene.Object;
import hxd.Res;

class Player extends HexObject {
  
  var lastTiles:Array<HexTile>;
  var char:Object;
  var angle:Float = 0;
  var target:Float = 0;
  var tx:Float;
  var ty:Float;
  
  public function new(?parent, tx:Int, ty:Int)
  {
    super(parent, tx, ty);
    char = new Object(this);
    var m = Main.cache.loadModel(Res.models.char);
    // var outline = Main.cache.loadModel(Res.models.char);
    // // outline.scale(1.1);
    // var out = new h3d.shader.Outline();
    // out.distance = 0;
    // out.size = 0.1;
    // out.color.setColor(0xff221111);
    // var mat = outline.getMaterials()[0];
    // mat.mainPass.addShader(out);
    // mat.mainPass.culling = Front;
    // for (mat in m.getMaterials())
    // {
    //   mat.mainPass.culling = Back;
    // }
    
    Util.addModelOutline(char, Res.models.char_outline);
    z = Const.HEX_TOP;
    // this.tox = Const.HEX_WIDTH / 2;
    // this.toy = Const.HEX_HEIGHT / 2;
    char.y += Const.HEX_HEIGHT / 2;
    
    // char.addChild(outline);
    char.addChild(m);
    // m.z = m.getBounds().zMin;
  }
  
  override public function setHexPos(q:Int, r:Int, s:Int)
  {
    super.setHexPos(q, r, s);
    tx = x;
    ty = y;
  }
  
  public function goTo(tile:HexTile)
  {
    var coord = tile.pos;
    target = this.pos.sub(coord).angle();
    // char.setRotation(0, 0, this.pos.sub(coord).angle());
    // setHexPos(coord.q, coord.r, coord.s);
    pos.set(coord.q, coord.r, coord.s);
    tx = pos.screenX();
    ty = pos.screenY();
    GameMap.current.selection.hide();
    
    SoundSystem.playMusicDist(Std.int(Math.sqrt(pos.cx*pos.cx+pos.cy*pos.cy)));
    State.step(tile);
  }
  
  override public function update()
  {
    angle = hxd.Math.angleLerp(angle, target, 5 * Timer.dt);
    char.setRotation(0, 0, angle);
    this.x = hxd.Math.lerp(x, tx, 16 * Timer.dt);
    this.y = hxd.Math.lerp(y, ty, 16 * Timer.dt);
    super.update();
  }
  
  override function sync(ctx:RenderContext)
  {
    super.sync(ctx);
  }
  
  override public function step()
  {
    if (lastTiles != null)
    {
      for (t in lastTiles) t.enabled = false;
    }
    var t = GameMap.current.findTile(pos);
    lastTiles = t.neighbors.copy();
    lastTiles.push(t);
    var snds = [Res.sfx.ld_sfx_step1, Res.sfx.ld_sfx_step2, Res.sfx.ld_sfx_step3, Res.sfx.ld_sfx_step4];
    SoundSystem.play(snds[Std.int(Math.random()*4)]);
    if (lastTiles != null)
    {
      for (t in lastTiles) t.enabled = t.isWalkable();
    }
    super.step();
  }
  
}