package owlbt.core;

class Decorator<T> {
  
  public var periodic:Bool = false;
  public var inverse:Bool = false;
  
  public function evaluate(ctx:T):Bool
  {
    return false;
  }
  
}