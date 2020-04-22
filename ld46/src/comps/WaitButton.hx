package comps;

import h2d.Layers;
import h2d.Interactive;

class WaitButton extends Interactive {
  
  public var btn:Button;
  
  public function new(parent:Layers) {
    super(58, 62);
    backgroundColor = 0xff111122;
    parent.add(this, 6);
    cursor = Default;
    btn = new Button(R.xsub(0, 213, 32, 32, 3), this);
    btn.setPosition(13, 15);
    btn.onOver = (_) -> State.i.projected = 1;
    btn.onOut = (_) -> State.i.projected = 0;
    btn.onClick = (_) -> State.i.advance(1);
    visible = false;
    Tooltip.attach("I have nothing else to do but wait.", btn);
  }
  
}