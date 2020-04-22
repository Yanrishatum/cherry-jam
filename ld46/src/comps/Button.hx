package comps;

import h2d.RenderContext;
import h2d.Tile;
import h2d.ui.CustomButton;

class Button extends CustomButton implements IButtonStateView {
  
  var curr:Tile;
  var states:Array<Tile>;
  var doSfx:Bool;
  public static var shiftDown:Bool = true;
  
  public function new (states:Array<Tile>, ?parent) {
    this.states = states;
    doSfx = true;
    processStates(states);
    super(states[0].width, states[0].height, parent, null, [this]);
    onClickEvent.add((_) -> if (doSfx) R.click());
  }
  
  inline function processStates(s:Array<Tile>) {
    if (s.length == 1) s.push(s[0]);
    if (s.length == 2) {
      s.push(s[1].clone());
      if (shiftDown) s[2].dy++;
    }
    s.insert(1, s[1]);
  }
  
  public function setState(state:ButtonState, flags:ButtonFlags) {
    curr = states[state];
  }
  
  override function draw(ctx:RenderContext)
  {
    emitTile(ctx, curr);
    super.draw(ctx);
  }
  
}