package comps;

import State;
import h2d.Object;
import h2d.col.Bounds;
import hxd.Timer;
import h2d.Layers;
import hxd.Event;
import h2d.ui.EventInteractive;
import h2d.RenderContext;
import h2d.Tile;
import h2d.Interactive;

class ActionButton extends EventInteractive {
  
  var t:Tile;
  var baseX:Float;
  var baseY:Float;
  var dragX:Float;
  var dragY:Float;
  var isDrag:Bool;
  
  var type:ActionName;
  
  public function new(index:Int, type:ActionName, ?parent:Layers) {
    
    super(26, 18);
    this.type = type;
    x = baseX = 260 + (index % 2) * (26+4);
    y = baseY = 115 + Std.int(index / 2) * (18+3);
    t = R.a.sub(45 + 23*index, 30, 22, 14, 2, 2);
    parent.add(this, 5);
    var tt = Tooltip.bindResource(Tooltip.attach("", this), type, type.name() + ": 0\nNone left!");
    parent.add(tt, 6);
  }
  
  override function draw(ctx:RenderContext) {
    super.draw(ctx);
    emitTile(ctx, t);
  }
  
  override public function getBounds(?relativeTo:Object, ?out:Bounds):Bounds
  {
    out = super.getBounds(relativeTo, out);
    addBounds(relativeTo, out, t.dx, t.dy, t.width, t.height);
    return out;
  }
  
  override public function onOver(e:Event)
  {
    if (State.i.resources[type] < 1) return; // Disable 
    State.i.projected = type.cost();
  }
  override public function onOut(e:Event)
  {
    if (State.i.resources[type] < 1) return; // Disable 
    State.i.projected = 0;
  }
  
  override public function onPush(e:Event) {
    if (State.i.resources[type] < 1) return; // Disable 
    dragX = e.relX;
    dragY = e.relY;
    isDrag = true;
    scene.startDrag(onDrag, null, e);
    cast(parent, Layers).over(this);
    // filter = new h2d.filter.DropShadow();
    filter = new h2d.filter.Bloom();
  }
  
  function onDrag(e:Event) {
    switch (e.kind) {
      case EMove:
        x = e.relX - dragX;
        y = e.relY - dragY;
        State.i.projected = type.cost();
      case ERelease:
        scene.stopDrag();
        State.i.projected = 0;
        if (Main.game.pet.getBounds().contains(new h2d.col.Point(e.relX, e.relY)) && Main.game.pet.action(type)) {
          x = baseX;
          y = baseY;
          alpha = 0;
        }
        filter = null;
        isDrag = false;
      default: 
    }
  }
  
  override function sync(ctx:RenderContext)
  {
    if (!isDrag && (x != baseX || y != baseY)) {
      // var angle = Math.atan2(baseY - y, baseX - x);
      if (hxd.Math.distanceSq(baseX - x, baseY - y) < .2) {
        x = baseX;
        y = baseY;
      } else {
        x = hxd.Math.lerp(x, baseX, 8 * Timer.dt);
        y = hxd.Math.lerp(y, baseY, 8 * Timer.dt);
      }
    }
    if (alpha < 1) {
      alpha += Timer.dt;
      if (alpha > 1) alpha = 1;
    }
    if (State.i.resources[type] < 1 && alpha > 0.5) alpha = 0.5;
    super.sync(ctx);
  }
  
}