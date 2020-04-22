package comps;

import State;
import h2d.RenderContext;
import h2d.Tile;
import h2d.Text;
import h2d.Object;

class ResourceView extends Object {
  
  var isShort:Bool;
  var txt:Text;
  var res:ActionName;
  static var pixel:Tile;
  
  public function new(res, short:Bool, ?parent) {
    super(parent);
    this.res = res;
    txt = new Text(R.digits, this);
    isShort = short;
    if (pixel == null) {
      pixel = Tile.fromColor(0x9999cc, 1, 1);
      pixel.dx = 5;
      pixel.dy = 3;
    };
  }
  
  override function draw(ctx:RenderContext)
  {
    if (isShort && State.i.resources[res] > 9) emitTile(ctx, pixel);
    super.draw(ctx);
  }
  
  override function sync(ctx:RenderContext)
  {
    var t = (isShort && State.i.resources[res] > 9 ? 9 : State.i.resources[res]) + "";
    if (txt.text != t) txt.text = t;
    super.sync(ctx);
  }
  
  
}