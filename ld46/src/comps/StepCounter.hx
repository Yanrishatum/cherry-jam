package comps;

import h2d.Tile;
import h2d.Flow;
import h2d.RenderContext;
import h2d.Object;

class StepCounter extends Object {
  
  var expired:Tile;
  var upcoming:Tile;
  var projected:Tile;
  
  public function new(?parent) {
    super(parent);
    expired = R.a.sub(27+3, 50, 2, 4);
    upcoming = R.a.sub(27, 50, 2, 4);
    projected = R.a.sub(27+6, 50, 2, 4);
    y = 2;
    x = R.W >>1;
  }
  
  override function draw(ctx:RenderContext)
  {
    var s = State.i;
    var max = s.config.stages[s.stage];
    var dx = Std.int(-(max * 3 / 2)) - 1;
    var m = max - s.step - s.projected;
    var i = 0;
    while (i < m) {
      expired.dx = dx;
      emitTile(ctx, expired);
      dx += 3;
      i++;
    }
    m += s.projected;
    while (i < m) {
      projected.dx = dx;
      emitTile(ctx, projected);
      dx += 3;
      i++;
    }
    while (i < max) {
      upcoming.dx = dx;
      emitTile(ctx, upcoming);
      dx += 3;
      i++;
    }
    super.draw(ctx);
  }
  
}