package owlbt.core;

class Node<T>
{
  
  public var decorators:Array<Decorator<T>> = new Array();
  // TODO: Services
  
  public function canEvaluate(ctx:T):Bool
  {
    // for (d in decorators) if (!d.evaluate(ctx)) return false;
    for (d in decorators) if (d.inverse ? d.evaluate(ctx) : !d.evaluate(ctx)) return false;
    return true;
  }
  
  public function evaluate(ctx:T):Result
  {
    return Failure;
  }
  
}