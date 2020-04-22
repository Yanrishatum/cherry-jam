package comps;

import h2d.RenderContext;
import h2d.ui.CustomButton;
import h2d.ui.CustomButton;
import h2d.Tile;

class LButton extends Button {
  
  var currL:Array<Tile>;
  var layers:Array<Array<Tile>>;
  var flagLayers:Map<ButtonFlags, Array<Array<Tile>>>;
  
  public function new(states:Array<Array<Tile>>, ?parent) {
    layers = states;
    var ml = layers.shift();
    for (s in states) {
      processStates(s);
    }
    flagLayers = [];
    super(ml, parent);
  }
  
  public function addFlags(flags:ButtonFlags, states:Array<Array<Tile>>) {
    for (s in states) processStates(s);
    flagLayers.set(flags, states);
  }
  
  override public function setState(state:ButtonState, flags:ButtonFlags)
  {
    super.setState(state, flags);
    if (flagLayers.exists(flags)) {
      currL = [for (l in flagLayers[flags]) l[state]];
      curr = currL.shift();
    } else {
      currL = [for (l in layers) l[state]];
    }
  }
  
  override function draw(ctx:RenderContext)
  {
    super.draw(ctx);
    for (l in currL) emitTile(ctx, l);
  }
  
}