package ld45;

import Util;

class HexObject extends UpdateObject {
  
  public var pos:HexCoord;
  public var tox:Float = 0;
  public var toy:Float = 0;
  
  public function new(?parent, tx:Int = 0, ty:Int = 0)
  {
    super(parent);
    pos = new HexCoord();
    pos.setOffset(tx, ty);
    pos.calcPosition(this, tox, toy);
  }
  
  public function setHexPos(q:Int, r:Int, s:Int)
  {
    pos.set(q, r, s);
    pos.calcPosition(this, tox, toy);
  }
  
}