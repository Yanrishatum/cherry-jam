package owlbt.core;

class Sequence<T> extends Composite<T> {
  
  public function new() {}
  
  override public function evaluate(ctx:T):Result
  {
    for (c in children)
    {
      if (!c.canEvaluate(ctx)) return Failure;
      
      var status = c.evaluate(ctx);
      if (status != Success) return status;
    }
    return Success;
  }
  
}