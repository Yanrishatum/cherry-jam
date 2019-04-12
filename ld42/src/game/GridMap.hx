package game;
import h2d.col.IPoint;
import haxe.ds.Vector;
import game.comps.MapHex;

class GridMap
{
  
  public static var instance:GridMap;
  
  private static var pt:IPoint = new IPoint();
  public static function moveCoord(x:Int, y:Int, dir:Int):IPoint
  {
    var stagger:Int = y % 2;
    switch (dir)
    {
      case 0:
        x++;
      case 1:
        y++;
        x += stagger;
      case 2:
        y++;
        x -= 1 - stagger;
      case 3:
        x--;
      case 4:
        y--;
        x -= 1 - stagger;
      case 5:
        y--;
        x += stagger;
    }
    pt.set(x, y);
    return pt;
  }
  
  public var map:Vector<MapHex>;
  public var width:Int;
  public var height:Int;
  
  public function new(width:Int, height:Int)
  {
    instance = this;
    this.map = new Vector(width * height);
    this.width = width;
    this.height = height;
    var x:Int = 0;
    var y:Int = 0;
    for(i in 0...map.length)
    {
      map[i] = new MapHex(x, y);
      if (++x == width) { x = 0; y++; }
    }
  }
  
  private function hexAt(x:Int, y:Int):MapHex
  {
    var idx:Int = y * width + x;
    if (x < 0 || y < 0 || x >= width || y >= height)
    {
      return null;
    }
    return map[idx];
  }
  
  public inline function tile(x:Int, y:Int):MapHex
  {
    return hexAt(x, y);
  }
  
  public function setTile(x:Int, y:Int, type:HexType):Void
  {
    var hex:MapHex = hexAt(x, y);
    if (hex != null)
    {
      hex.setType(type);
    }
  }
  
  public function fill(data:Array<HexType>):Void
  {
    var i:Int = 0;
    for(hex in map)
    {
      hex.setType(data[i++]);
    }
  }
  
}