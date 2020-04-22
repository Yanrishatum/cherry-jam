package owlbt.core;

class Selector<T> extends Composite<T>
{
  
  public function new() {}
  
  override public function evaluate(ctx:T):Result
  {
    for (c in children)
    {
      if (c.canEvaluate(ctx))
      {
        var status = c.evaluate(ctx);
        if (status != Failure) return status;
      }
    }
    return Failure;
  }
  
}