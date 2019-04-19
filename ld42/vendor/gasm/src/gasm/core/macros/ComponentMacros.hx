package gasm.core.macros;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Tools;

/**
 * ...
 * @author Leo Bergman
 */
class ComponentMacros {
    static var _index:Int = 0;
    static var _types:Map<String, Int> = new Map<String, Int>();

    #if macro
	/**
	 * Will add name getters and constants to Components to speed up resolution.
	 */
	public static function build():Array<Field> 
	{
		var pos = Context.currentPos();
		var classType:ClassType = Context.getLocalClass().get();
		
		var name = Context.makeExpr(makeComponentName(classType), pos);	
		
		var superClassType:ClassType;
		while (true) 
		{
			superClassType = classType.superClass.t.get();
            if (superClassType.meta.has(":componentAbstract") ) {
                break;
            }
			classType = superClassType;
        }
		var baseName = Context.makeExpr(makeComponentName(classType), pos);
		
		var c = macro : {
			override public function get_name() {
				return $name;
			}
			override public function get_baseName() {
				return $baseName;
			}
			public static var BASE_NAME:String = $baseName;
		};
		
		switch (c) {
			case TAnonymous(fields):
				return Context.getBuildFields().concat(fields);
			default:
				throw 'unreachable';
		}
		
	}
	
	static private function makeComponentName(classType:ClassType):String
	{
		var componentName = classType.pack.join(".") + "." + classType.name;
		return componentName;
	}
	#end
}