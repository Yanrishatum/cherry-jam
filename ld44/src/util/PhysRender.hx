package util;

import differ.math.Vector;
import differ.data.ShapeCollision;
import differ.shapes.Shape;
import differ.shapes.Polygon;
import differ.shapes.Circle;
import h2d.Object;
import h2d.Graphics;

class PhysRender extends differ.ShapeDrawer {
  
  public var g:Graphics;
  var colSet:Int;
  public var color:Int = 0xff0000;
  public var alpha:Float = 0.5;
  
  public function new(parent:Object)
  {
    colSet = 0;
    g = new Graphics(parent);
    super();
  }
  
  public function clear()
  {
    g.clear();
  }
  
  
  
  override public function drawLine(p0x:Float, p0y:Float, p1x:Float, p1y:Float, ?startPoint:Bool = true)
  {
    setCol();
    if (startPoint) g.moveTo(p0x, p0y);
    else g.lineTo(p0x, p0y);
    g.lineTo(p1x, p1y);
    resetCol();
  }
  
  override public function drawCircle(circle:Circle)
  {
    setCol();
    super.drawCircle(circle);
    resetCol();
  }
  
  override public function drawPoint(x:Float, y:Float, size:Float = 4)
  {
    setCol();
    super.drawPoint(x, y, size);
    resetCol();
  }
  
  override public function drawPolygon(poly:Polygon)
  {
    setCol();
    super.drawPolygon(poly);
    resetCol();
  }
  
  override public function drawShape(shape:Shape)
  {
    setCol();
    super.drawShape(shape);
    resetCol();
  }
  
  override public function drawShapeCollision(c:ShapeCollision, ?length:Float = 30)
  {
    setCol();
    super.drawShapeCollision(c, length);
    resetCol();
  }
  
  override private function drawVertList(_verts:Array<Vector>)
  {
    setCol();
    super.drawVertList(_verts);
    resetCol();
  }
  
  inline function setCol()
  {
    if (colSet++ == 0) 
    {
      g.beginFill(color, alpha);
    }
    g.lineStyle(2, color);
  }
  
  inline function resetCol()
  {
    if (--colSet == 0) g.endFill();
  }
  
}