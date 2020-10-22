package ldx.comps;

import h2d.RenderContext;
import h2d.Text;
import h2d.ScaleGrid;
import h2d.Bitmap;
import ch2.ui.CustomButton;

class MenuButton extends CustomButton implements IButtonStateView {
  
  var bg:ScaleGrid;
  var label:Text;
  var dt:Float = 0;
  var target:Float = 0;
  
  public function new(text:String, ?parent) {
    super(100, 20, parent);
    
    bg = new ScaleGrid(Utils.allocSDFTile(32, 32, 0xffffff), 8, 8, this);
    var sdf = new ldx.shader.SDFRect();
    sdf.radius = 8 / 64;
    bg.addShader(sdf);
    bg.color.setColor(R.IDLE_COLOR);
    
    label = new Text(R.font, this);
    label.textAlign = Center;
    label.maxWidth = width;
    label.listenText(text);
    label.y = 5;
    height = label.textHeight + 10;
    
    bg.width = this.width;
    bg.height = this.height - 0.5;
    
    this.views.push(this);
    setState(state, flags);
  }
  
  public function setState(state:ButtonState, flags:ButtonFlags) {
    switch (state) {
      case Hold: target = 1;
      case Hover: target = 1;
      case Idle: target = 0;
      case Press: target = 1;
    }
  }
  
  override function sync(ctx:RenderContext)
  {
    if (dt > target) {
      dt -= ctx.elapsedTime * 4;
      if (dt < target) dt = target;
      bg.color.setColor(hxd.Math.colorLerp(R.IDLE_COLOR, R.ACTIVE_COLOR, dt));
    } else if (dt < target) {
      dt += ctx.elapsedTime * 4;
      if (dt > target) dt = target;
      bg.color.setColor(hxd.Math.colorLerp(R.IDLE_COLOR, R.ACTIVE_COLOR, dt));
    }
    super.sync(ctx);
  }
  
  override function constraintSize(maxWidth:Float, maxHeight:Float)
  {
    width = Math.round(maxWidth) - 0.5;
    label.maxWidth = width;
    bg.width = width;
    super.constraintSize(maxWidth, maxHeight);
  }
  
}