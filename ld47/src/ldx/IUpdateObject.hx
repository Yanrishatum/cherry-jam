package ldx;

interface IUpdateObject {
  
  public var priority:Float;
  
  public function preUpdate():Void;
  public function update():Void;
  public function fixedUpdate():Void;
  public function postUpdate():Void;
  
  // For turn-based
  public function step():Void;
}