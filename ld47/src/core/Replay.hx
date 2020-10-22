package core;

import hxd.Key;

interface InputProvider {
  
  public function hasNext():Bool;
  public function next():InputBase;
  public function current():InputBase;
  
}

class Replay implements InputProvider {
  
  public var frames:Array<ReplayFrame>;
  public var time:Float;
  public var recording:Bool;
  var caret:Int;
  
  public function new() {
    reset();
  }
  
  public function reset() {
    frames = [];
    recording = true;
    time = 0;
  }
  
  public function start() {
    recording = false;
    caret = 0;
  }
  
  public function hasNext():Bool {
    return !recording && caret < frames.length;
  }
  
  public function current() {
    return frames[caret];
  }
  
  public function next():InputBase {
    return frames[caret++];
  }
  
}

class InputBase {
  public var keyPress:Array<Int>;
  
	public function isDown( code : Int ) {
		return keyPress[code] > 0;
	}

	inline function getFrame() {
		return GameTimer.frame - 2;
	}

	public function isPressed( code : Int ) {
		return keyPress[code] == getFrame() - 1;
	}

	public function isReleased( code : Int ) {
		return keyPress[code] == -getFrame() + 1;
	}
}

class ReplayFrame extends InputBase {
  
  public function new(keys:Array<Int>) {
    keyPress = keys.copy();
  }
  
  public var px:Float;
  public var py:Float;
  
}

class RawInput extends InputBase implements InputProvider {
  
  var timer:GameTimer;
  
  public function new(timer:GameTimer) {
    this.timer = timer;
  }
  
  override public function isDown(code:Int):Bool
  {
		return timer.keyPressed[code] > 0;
  }
  
  override public function isPressed(code:Int):Bool
  {
    return timer.keyPressed[code] == getFrame() + 1;
  }
  
  override public function isReleased(code:Int):Bool
  {
    return timer.keyPressed[code] == -getFrame() - 1;
  }
  
  public function hasNext() return true;
  public function next() return this;
  public function current() return this;
  
}