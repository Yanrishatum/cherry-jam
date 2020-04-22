package game;

import h2d.Object;
import differ.shapes.Polygon;

class TrackSegment extends Object {
  
  public var track:Track;
  public var polys:Map<Int, Array<Polygon>>;
  
  public function new(t:Track, x:Int, y:Int, polys:Map<Int, Array<Polygon>>)
  {
    this.track = t;
    this.polys = polys;
    super(t);
    
  }
  
  override private function onAdd()
  {
    for (kv in polys.keyValueIterator())
    {
      for(p in kv.value)
        Physics.addStatic(kv.key, p);
    }
    super.onAdd();
  }
  
  override private function onRemove()
  {
    for (kv in polys.keyValueIterator())
    {
      for(p in kv.value)
        Physics.removeStatic(kv.key, p);
    }
    super.onRemove();
  }
  
}