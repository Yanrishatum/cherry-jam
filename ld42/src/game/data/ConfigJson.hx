package game.data;
import game.data.MagicRef.MagicRefJson;

typedef ConfigJson =
{
  var map_index:Array<String>;
  var map:Array<String>;
  var stats:Dynamic;
  var spells:Array<MagicRefJson>;
}

typedef CharJson =
{
  var hp:Float;
  var atk:Float;
  var atb:Float;
  var spells:Array<String>;
  var ai:Bool;
  var x:Int;
  var y:Int;
}