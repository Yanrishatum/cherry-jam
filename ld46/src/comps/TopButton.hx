package comps;

import h2d.RenderContext;
import h2d.Tile;
import h2d.ui.CustomButton;

class TopButton extends CustomButton implements IButtonStateView {
  
  var curr:Tile;
  var txt:Tile;
  var states:Array<Tile>;
  var txtStates:Array<Tile>;
  
  public function new(flip:Bool, text:Array<Tile>, ?parent)
  {
    var sl = R.xsub(0, 16, 46, 13, 3, 1, 4, 4);
    if (flip) for (s in sl) {
      s.flipX();
      s.dx = 4;
    }
    sl.insert(1, sl[1]);
    states = sl;
    txtStates = text;
    if (text.length == 2) {
      text.push(text[1].clone());
      text[2].dy++;
    }
    for (t in text) {
      t.dx += sl[0].dx;
      t.dy += sl[0].dy;
    }
    text.insert(1, text[1]);
    super(54, 21, parent, [this]);
    onClickEvent.add(R.clickE);
  }
  
  public function setState(state:ButtonState, flags:ButtonFlags) {
    curr = states[state];
    txt = txtStates[state];
  }
  
  override function draw(ctx:RenderContext)
  {
    emitTile(ctx, curr);
    emitTile(ctx, txt);
  }
  
}