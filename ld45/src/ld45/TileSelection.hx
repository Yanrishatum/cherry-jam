package ld45;

import h3d.scene.Mesh;
import Util;
import hxd.Res;
import h3d.scene.Object;

class TileSelection extends HexObject {
  
  var sel:Mesh;
  
  public function new(?parent)
  {
    super(parent);
    visible = false;
    sel = Main.cache.loadModel(Res.models.tile_selection).toMesh();
    addChild(sel);
    sel.z = Const.HEX_TOP;
  }
  
  public function show(at:HexCoord)
  {
    visible = true;
    if (at.equals(GameMap.current.player.pos))
    {
      sel.material.color.set(0.4, 1, 0.4);
    }
    else 
    {
      sel.material.color.set(1,1,1);
    }
    setHexPos(at.q, at.r, at.s);
  }
  
  public function hide()
  {
    visible = false;
  }
  
}