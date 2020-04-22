package ld45;

import hxd.snd.SoundGroup;
import yatl.VariableTween;
import hxd.snd.Channel;
import hxd.res.Sound;
import hxd.Res;

class SoundSystem {
  
  static var cur:Sound;
  static var curChan:Channel;
  
  public static var music:SoundGroup = new SoundGroup("music");
  public static var sfx:SoundGroup = new SoundGroup("sfx");
  
  public static function playMusic(snd:Sound, loop = true)
  {
    if (cur != null && snd.name == cur.name) return;
    var pos = 0.;
    if (curChan != null)
    {
      // pos = curChan.position;
      var c = curChan;
      // c.stop();
      c.fadeTo(0, 1, () -> c.stop());
    }
    
    curChan = snd.play(loop, 1, music);
    // curChan.position = pos;
    curChan.volume = 0;
    curChan.fadeTo(1, 1);
    // curChan.volume = 0;
    // var f = new FadeIn();
    // f.setup(curChan, 1, 1);
    cur = snd;
  }
  
  public static function play(sound:Sound)
  {
    sound.play(false, 0.5, sfx);
  }
  
  public static function playMusicDist(distance)
  {
    var snd = 
    if (distance < State.config.pool.dist_easy) Res.sfx.ld_track_main1;
    else if (distance < State.config.pool.dist_normal) Res.sfx.ld_track_main2;
    else Res.sfx.ld_track_main3;
    playMusic(snd);
  }
  
}

@:tween(volume)
class FadeIn extends VariableTween<Channel>
{
  
  override function onTweenFinish()
  {
    if (target.volume == 0) target.stop();
    super.onTweenFinish();
  }
}