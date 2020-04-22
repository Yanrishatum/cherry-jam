package owlbt.core;

typedef OwlbtRoot = {
  >OwlbtNode,
  var name:String;
}

typedef OwlbtNode = {
  var type:String;
  var childNodes:Array<OwlbtNode>;
  var decorators:Array<OwlbtDecorator>;
  var servieces:Array<OwlbtService>;
  var properties:OwlbtProperties;
}

typedef OwlbtDecorator = {
  var type:String;
  var periodic:Bool;
  var inverseCheckCondition:Bool;
  var properties:OwlbtProperties;
}

typedef OwlbtService = {
  var type:String;
  var properties:OwlbtProperties;
}

abstract OwlbtProperties(Array<OwlbtProperty>) {
  
  public inline function get<T>(name:String, def:T):T
  {
    var v = def;
    for (p in this) if (p.name == name) { v = p.value; break; }
    return v;
  }
  
  public inline function getString(name:String, def:String = null):String
  {
    var v = def;
    for (p in this) if (p.name == name) { v = Std.string(p.value); break; }
    return v;
  }
  
  public inline function getFloat(name:String, def:Float = 0):Float
  {
    var v = def;
    for (p in this) if (p.name == name) { v = p.value; break; }
    return v;
  }
  
  public inline function getInt(name:String, def:Int = 0):Int
  {
    var v = def;
    for (p in this) if (p.name == name) { v = p.value; break; }
    return v;
  }
  
}

typedef OwlbtProperty = {
  var name:String;
  var value:Dynamic;
}