package comps;

import hxd.snd.Channel;
import hxd.Res;
import hxd.res.Sound;
import h2d.RenderContext;
import hxd.snd.ChannelGroup;
import h2d.Slider;
import hxd.snd.SoundGroup;
import h2d.Object;

class VolumeSlider extends Object {
  
  var mute:LButton;
  var slider:Slider;
  var group:ChannelGroup;
  var sfxLoop:Sound;
  var sfxChan:Channel;
  
  public function new(isSfx:Bool, ?parent) {
    super(parent);
    group = isSfx ? R.sfx : R.music;
    mute = new LButton([R.xsub(isSfx ? 90 : 45, 132, 14, 13, 3)], this);
    mute.addFlags(Toggled, [
      R.xsub(isSfx ? 90 : 45, 132, 14, 13, 3),
      [R.a.sub(138, 132, 12, 3, 1, 4)]
    ]);
    slider = new CustomSlider(52, 9, this);
    slider.x = 16;
    slider.y = 2;
    slider.minValue = 0;
    slider.maxValue = 1;
    slider.value = group.mute ? 0 : group.volume;
    slider.tile = R.a.sub(135, 132, 2, 9);
    mute.setFlag(Toggled, group.mute);
    slider.onChange = function() {
      group.mute = false;
      mute.setFlag(Toggled, false);
      group.volume = slider.value;
      R.saveSettings();
    }
    mute.onClick = function(_) {
      group.mute = !group.mute;
      mute.setFlag(Toggled, group.mute);
      slider.value = group.mute ? 0 : group.volume;
      R.saveSettings();
    }
    if (isSfx) {
      sfxLoop = Res.sound.sfxtest;
      slider.onPush = function(_) {
        if (sfxChan == null || sfxChan.isReleased()) {
          sfxChan = sfxLoop.play(true, 1, R.sfx);
        } else {
          sfxChan.fadeTo(1, 0.5);
        }
      }
      slider.onRelease = (_) -> {
        if (sfxChan != null) {
          sfxChan.fadeTo(0, 0.5, () -> sfxChan.stop());
        }
      }
      
    }
  }
  
}

class CustomSlider extends Slider
{
  
  public function new(w, h, p) {
    super(w, h, p);
    cursorTile.setSize(1, height);
  }
  
  override function draw(ctx:RenderContext)
  {
    var x = 1;
    var px = getDx() + 1;
    if (value > minValue) {
      while (x < px) {
        tile.dx = x;
        emitTile(ctx, tile);
        x += 3;
      }
      if (value == maxValue) {
        tile.dx = x;
        emitTile(ctx, tile);
      }
    }
  }
  
}