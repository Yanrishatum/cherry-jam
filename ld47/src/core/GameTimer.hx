package core;

import hxd.Timer;
import core.Replay;
import hxd.Key;
import hxd.Event;

class GameTimer {
  
  public static var frame:Int;
  
  public var keyPressed:Array<Int> = [];
  public var replay:Replay;
  public var time:Float;
  
  public function new() {
    State.window.addEventTarget(handleEvents);
    #if debug
    State.game.ui.ov.stat(() -> (Math.round(time * 100) / 100) + "s / " + frame, "Time");
    #end
    start();
  }
  
  public function dispose() {
    State.window.removeEventTarget(handleEvents);
  }
  
  function handleEvents(e:Event):Void {
		switch( e.kind ) {
		case EKeyDown:
      if (keyPressed[e.keyCode] > 0) return;
			keyPressed[e.keyCode] = frame;
		case EKeyUp:
			keyPressed[e.keyCode] = -frame;
		case EPush:
			if( e.button < 5 ) keyPressed[e.button] = frame;
		case ERelease:
			if( e.button < 5 ) keyPressed[e.button] = -frame;
		case EWheel:
			keyPressed[e.wheelDelta > 0 ? Key.MOUSE_WHEEL_DOWN : Key.MOUSE_WHEEL_UP] = frame;
		default:
		}
  }
  
  
  public function update() {
    frame++;
    time += 1 / Timer.wantedFPS;
    var f = new ReplayFrame(this.keyPressed);
    f.px = State.game.player.vx;
    f.py = State.game.player.vy;
    replay.frames.push(f);
    replay.time = time;
  }
  
  public function start() {
    frame = 2;
    time = 0;
    replay = new Replay();
    // keyPressed = [];
  }
  
}