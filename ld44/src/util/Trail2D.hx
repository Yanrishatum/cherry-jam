package util;

import h3d.Vector;
import h2d.col.Point;
import h2d.Object;
import h2d.Graphics;

class Trail2D extends Graphics
{
  
  var lastPos:Map<Int, Vector>;
  var mainColor:Int;
  var mainAlpha:Float;
  var hw:Float;
  
  public function new(color:Int, alpha:Float, width:Float, ?parent:Object)
  {
    super(parent);
    hw = width / 2;
    this.mainColor = color;
    this.mainAlpha = alpha;
    lastPos = new Map();
  }
  
  public function cut()
  {
    lastPos = new Map();
  }
  
  public function add(id:Int, x:Float, y:Float, angle:Float)
  {
    var last = lastPos[id];
    angle += Math.PI * .5;
    var cos = Math.cos(angle);
    var sin = Math.sin(angle);
    if (last == null) 
    {
      lastPos[id] = new Vector(x + cos * hw, y + sin * hw, x - cos * hw, y - sin * hw);
      return;
    }
    beginFill(mainColor, mainAlpha);
    moveTo(last.x, last.y);
    lineTo(last.z, last.w);
    last.set(x + cos * hw, y + sin * hw, x - cos * hw, y - sin * hw);
    lineTo(last.z, last.w);
    lineTo(last.x, last.y);
  }
  
}