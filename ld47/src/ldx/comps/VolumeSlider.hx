package ldx.comps;

import h3d.mat.Texture;
import h2d.Tile;
import hxd.snd.ChannelGroup;
import hxd.Res;
import ch2.ui.CustomButton;
import h2d.Bitmap;
import h2d.Text;
import h2d.Slider;
import h2d.Flow;

class VolumeSlider extends Flow {
  
  var label:Text;
  var toggle:CustomButton;
  var toggleOn:Bitmap;
  var toggleOff:Bitmap;
  var slider:Slider;
  var display:Text;
  var sliderOffset:Float;
  
  var channel:ChannelGroup;
  
  static var circle:Tile;
  
  public function new(labelText:String, lw:Int = 100, channel:ChannelGroup, ?parent) {
    super(parent);
    this.channel = channel;
    maxHeight = 20;
    lineHeight = 20;
    horizontalSpacing = 4;
    verticalAlign = Top;
    var label = new Text(R.font, this);
    label.maxWidth = lw;
    label.textAlign = Right;
    label.listenText(labelText);
    getProperties(label).minWidth = Std.int(label.maxWidth);
    
    enableInteractive = true;
    
    var icons = Res.ldx.volume_icons.toTile().split(2);
    var isc = 20 / icons[0].height;
    toggle = new CustomButton(Std.int(icons[0].width * isc), Std.int(icons[0].height * isc), this);
    toggle.propagateEvents = true;
    toggleOn = new Bitmap(icons[0], toggle);
    toggleOn.width = toggle.width;
    toggleOn.smooth = true;
    toggleOff = new Bitmap(icons[1], toggle);
    toggleOff.width = toggle.width;
    toggleOff.smooth = true;
    toggle.views.push(new CallbackButtonState(updateToggle));
    toggle.setFlag(Toggled, !channel.mute);
    toggle.onClick = toggleMute;
    
    if (circle == null) {
      var circ = new Bitmap(Utils.allocSDFTile(20, 20, R.TEXT_COLOR));
      circ.addShader(new ldx.shader.SDFCircle());
      var circTex = new Texture(20, 20, [Target]);
      circTex.clearF(0, 0, 0, 0);
      circ.drawTo(circTex);
      circle = Tile.fromTexture(circTex);
    }
    
    slider = new Slider(50, 20, this);
    slider.cursorTile = circle;
    slider.onChange = changed;
    slider.propagateEvents = true;
    
    display = new Text(R.font, this);
    display.textAlign = Right;
    display.maxWidth = display.calcTextWidth("100%");
    getProperties(display).minWidth = Std.int(display.maxWidth+2);
    
    sliderOffset = label.maxWidth + display.maxWidth + horizontalSpacing * 2;
    setValue(channel.mute ? 0 : channel.volume);
  }
  
  function updateToggle(state:ButtonState, flags:ButtonFlags) {
    toggleOn.visible = flags.has(Toggled);
    toggleOff.visible = !toggleOn.visible;
    switch (state) {
      case Hold:
        toggleOn.color.setColor(0xff000000 | R.ACTIVE_COLOR);
        toggleOff.color.setColor(0xff000000 | R.ACTIVE_COLOR);
      case Hover:
        toggleOn.color.setColor(0xff000000 | R.ACTIVE_COLOR);
        toggleOff.color.setColor(0xff000000 | R.ACTIVE_COLOR);
      case Idle:
        toggleOn.color.setColor(0xff000000 | R.TEXT_COLOR);
        toggleOff.color.setColor(0xff000000 | R.TEXT_COLOR);
      case Press:
        toggleOn.color.setColor(0xff000000 | R.ACTIVE_COLOR);
        toggleOff.color.setColor(0xff000000 | R.ACTIVE_COLOR);
    }
  }
  
  override function constraintSize(width:Float, height:Float)
  {
    slider.width = width - sliderOffset;
    super.constraintSize(width, height);
  }
  
  function toggleMute(_) {
    channel.mute = !channel.mute;
    toggle.setFlag(Toggled, !channel.mute);
    setValue(channel.mute ? 0 : channel.volume);
  }
  
  function changed() {
    display.text = Math.round(slider.value * 100) + "%";
    channel.mute = false;
    channel.volume = slider.value;
    toggle.setFlag(Toggled, true);
    onChange(slider.value);
  }
  
  public function setValue(val:Float) {
    slider.value = val;
    display.text = Math.round(slider.value * 100) + "%";
  }
  
  public dynamic function onChange(v:Float) {
    
  }
  
}