package engine.utils;

import haxe.macro.ComplexTypeTools;
import haxe.macro.ExprTools;
import haxe.macro.TypeTools;
import haxe.macro.Type;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;

class MacroUtil
{
  
  public static macro function constructEngine():Expr
  {
    var engine = TypeTools.getClass( getEngine());
    var path:TypePath = { pack: engine.pack, name: engine.name };
    
    return macro new $path();
  }
  
  public static macro function resPath():haxe.macro.Expr
  {
		var dir = haxe.macro.Context.definedValue("resourcesPath");
		if( dir == null ) dir = "res";
    return macro $v{dir};
  }
  
  #if macro
  
  private static function getEngine():haxe.macro.Type
  {
    var engineClass:ClassType = TypeTools.getClass(Context.getType("engine.HPEngine"));
    var engineType:haxe.macro.Type;
    try
    {
      var t:haxe.macro.Type = Context.getType("Main");
      switch(t)
      {
        case haxe.macro.Type.TInst(ref, params):
          var ct:ClassType = ref.get();
          
          if (ct.superClass != null)
          {
            var nameA = engineClass.pack.join(".") + "." + engineClass.name;
            var sc:ClassType = ct.superClass.t.get();
            if (nameA == sc.pack.join(".") + "." + sc.name) return t;
          }
        default: // throw "Nope";
      }
    }
    catch(e:String)
    {
      Context.fatalError(e, Context.currentPos());
    }
    
    return engineType != null ? engineType : Context.getType("engine.HPEngine");
    
  }
  
  #end
  
}