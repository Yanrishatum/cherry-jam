package engine;

import hxd.snd.ChannelGroup;
#if !js
import hxd.snd.Channel;
#end
import engine.utils.Tween;
import engine.HXP;
import hxd.res.Sound;

#if js

class Channel
{
  private var _v:Float = 1;
  public var volume(get, set):Float;
  
  private function get_volume():Float
  {
    if (snd != null) return _v;
    else return _v;
  }
  
  private function set_volume(v:Float):Float
  {
    _v = v;
    if (snd != null) snd.volume = calcVol();
    // trace(snd.volume);
    return v;
  }
  
  private var chn:ChannelGroup;
  private var snd:js.html.Audio;
  
  public function new(source:String, loop:Bool, vol:Float, channel:ChannelGroup)
  {
    var file:String = source;
    snd = new js.html.Audio(file);
    _v = vol;
    this.chn = channel;
    snd.volume = calcVol();
    
    snd.loop = loop;
    snd.load();
  }
  
  public function play():Void
  {
    if (snd != null)
    {
      snd.autoplay = true;
      snd.play();
    }
  }
  
  public function stop():Void
  {
    if (snd != null)
    {
      snd.pause();
      snd = null;
    }
  }
  
  public function update():Void
  {
    var v:Float = calcVol();
    if (snd != null && v != snd.volume) snd.volume = v;
  }
  
  private function calcVol():Float
  {
    var f:Float = _v;
    if (chn != null)
    {
      if (chn.mute) return 0;
      f *= chn.volume;
    }
    return f;
  }
  
}

#end

@:allow(engine.HXP)
class Music
{
  
  private static function update(delta:Float):Void
  {
    #if js
    if (current != null) current.update();
    #end
    fadeouts = fadeouts.filter( (f) -> { f.update(delta); return f.working; });
  }
  
  private static var fadeouts:Array<MusicFade> = new Array();
  private static var current:Channel;
  private static var currentRes:String;
  
  public static function precache(?path:String, ?sound:Sound):Void
  {
    #if js
    new Channel(path == null ? sound.entry.path : path, false, 0, null);
    #end
  }
  
  #if js
  public static function play(?path:String, ?sound:Sound, force:Bool = false, immediate:Bool = false):Void
  #else
  public static function play(sound:Sound, force:Bool = false, immediate:Bool = false):Void
  #end
  {
    if (((sound != null && sound.entry.path == currentRes) #if js || path == currentRes #end) && !force) return;
    
    if (current != null)
    {
      stop();
    }
    #if js
    currentRes = path == null ? sound.entry.path : path;
    current = new Channel(path == null ? sound.entry.path : path, true, 0, HXP.musicChannel);
    current.play();
    // trace(sound.name);
    // trace(current.pause);
    // trace(current.mute);
    #else
    currentRes = sound.entry.path;
    current = sound.play(true, 0, HXP.musicChannel);
    #end
    // trace(current.priority = 100);
    if (immediate)
    {
      current.volume = 1;
    }
    else 
    {
      var fade:MusicFade = new MusicFade(current, 0, 1);
      fade.start();
      fadeouts.push(fade);
    }
  }
  
  public static function stop(immediate:Bool = false):Void
  {
    if (current != null)
    {
      if (immediate)
      {
        current.stop();
      }
      else 
      {
        var out:MusicFade = new MusicFade(current, current.volume, 0);
        out.start();
        fadeouts.push(out);
      }
      current = null;
      currentRes = null;
    }
  }
  
}

class MusicFade extends Tween
{
  
  private var ch:Channel;
  private var _start:Float;
  private var _move:Float;
  
  public function new(ch:Channel, from:Float, to:Float)
  {
    this.ch = ch;
    _start = from;
    _move = to - from;
    super(2);
  }
  
  override public function start(reset:Bool = true)
  {
    super.start(reset);
    ch.volume = _start;
  }
  
  override public function update(delta:Float)
  {
    super.update(delta);
    ch.volume = _start + _move * percent;
    // trace(delta, _start, _move, percent, elapsed, duration, ch.volume);
    if (ch.volume == 0 && _start != 0) ch.stop();
    #if js
    ch.update();
    #end
  }
  
}