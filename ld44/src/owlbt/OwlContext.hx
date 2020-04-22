package owlbt;

import owlbt.core.Data;
import owlbt.core.*;

class OwlContext<T> {
  
  public static function parse<T>(tree:OwlbtRoot, resolveNode:OwlbtNode->Node<T>, resolveDecorator:OwlbtDecorator->Decorator<T>):OwlContext<T>
  {
    return new OwlContext(parseRec(tree, resolveNode, resolveDecorator));
  }
  
  static function parseRec<T>(tree:OwlbtNode, resolveNode:OwlbtNode->Node<T>, resolveDecorator:OwlbtDecorator->Decorator<T>):Node<T>
  {
    var node:Node<T> = switch (tree.type)
    {
      case "Selector": new Selector();
      case "Sequence": new Sequence();
      default: resolveNode(tree);
    }
    if (node == null) return null;
    if (tree.childNodes != null && tree.childNodes.length > 0)
    {
      var composite:Composite<T> = Std.instance(node, Composite);
      if (composite != null)
      {
        for (child in tree.childNodes)
        {
          var childNode = parseRec(child, resolveNode, resolveDecorator);
          if (childNode != null) composite.children.push(childNode);
        }
      }
      // else throw "Node contains children, but is not a composite node!"
    }
    if (tree.decorators != null)
    {
      for (d in tree.decorators)
      {
        var dec = resolveDecorator(d);
        if (dec != null)
        {
          dec.periodic = d.periodic == true;
          dec.inverse = d.inverseCheckCondition == true;
          node.decorators.push(dec);
        }
      }
    }
    return node;
  }
  
  public var root:Node<T>;
  
  public function new(root:Node<T>)
  {
    this.root = root;
    // TODO: Flatten?
  }
  
  public inline function evaluate(ctx:T):Result
  {
    return root.evaluate(ctx);
  }
  
}