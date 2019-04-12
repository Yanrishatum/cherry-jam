package engine.utils;

import gasm.core.utils.Signal0;

class Tween
{
  
  public var elapsed(default, null):Float;
  public var duration(default, null):Float;
  public var percent(get, set):Float;
  private inline function set_percent(v:Float):Float
  {
    elapsed = duration * v;
    return v;
  }
  private inline function get_percent():Float
  {
    return elapsed / duration;
  }
  
  public var working:Bool;
  
  public var onFinished:Signal0 = new Signal0();
  
  public function new(duration:Float = 1)
  {
    this.elapsed = 0;
    this.duration = duration;
  }
  
  public function start(reset:Bool = true):Void
  {
    if (reset) this.reset();
    working = true;
  }
  
  public function reset():Void
  {
    this.elapsed = 0;
  }
  
  public function update(delta:Float):Void
  {
    if (!working) return;
    this.elapsed += delta;
    if (elapsed >= duration)
    {
      elapsed = duration;
      working = false;
      onFinished.emit();
    }
  }
  
}