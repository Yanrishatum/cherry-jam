package util;

import hxd.Key;

class Input
{
  
  public static var actions:Map<String, InputAction> = new Map();
  
  public static inline function register(name:String, act:InputAction)
    actions[name] = act;
  
  public static inline function get(name:String)
    return actions[name];
  
}

class InputAction
{
  
  public var keys:Array<KeyCombo>;
  
  public var up(get, never):Bool;
  public var down(get, never):Bool;
  public var pressed(get, never):Bool;
  public var released(get, never):Bool;
  
  public function new(keys:Array<KeyCombo>)
  {
    this.keys = keys;
  }
  
  function get_up():Bool return !down;
  function get_down():Bool
  {
    for (combo in keys)
    {
      var found = true;
      for (k in combo.arr())
      {
        if (!Key.isDown(k))
        {
          found = false;
          break;
        }
      }
      if (found) return true;
    }
    return false;
  }
  function get_pressed():Bool
  {
    for (combo in keys)
    {
      var found = true;
      var isPressed = false;
      for (k in combo.arr())
      {
        if (!Key.isDown(k))
        {
          found = false;
          break;
        }
        if (Key.isPressed(k)) isPressed = true;
      }
      if (found) return isPressed;
    }
    return false;
  }
  function get_released():Bool
  {
    for (combo in keys)
    {
      var found = true;
      var isPressed = false;
      for (k in combo.arr())
      {
        if (Key.isDown(k))
        {
          found = false;
          break;
        }
        if (Key.isReleased(k)) isPressed = true;
      }
      if (found) return isPressed;
    }
    return false;
  }
  
}

abstract KeyCombo(Array<Int>) from Array<Int> to Array<Int>
{
  
  @:from
  static inline function fromInt(v:Int):KeyCombo
  {
    return [v];
  }
  
  public inline function arr():Array<Int> return this;
  
}