package game;

class CarStats
{
  
  public var ref:Cars;
  public var acceleration(get, never):Float;
  public var deceleration(get, never):Float;
  public var drag(get, never):Float;
  public var friction(get, never):Float;
  public var handling(get, never):Float;
  public var handlingRange(get, never):Float;
  public var driftBonus(get, never):Float;
  public var maxSpeed(get, never):Float;
  public var hpPool(get, never):Float;
  
  public var bonusDecl:Float = 0;
  public var bonusAccl:Float = 0;
  public var bonusSpeed:Float = 0;
  public var bonusHandling:Float = 0;
  
  public function new(car:Cars)
  {
    this.ref = car;
  }
  
  inline function get_acceleration() return ref.acceleration + bonusAccl;
  inline function get_deceleration() return ref.deceleration + bonusDecl;
  inline function get_drag() return ref.drag;
  inline function get_handling() return ref.handling_ratio + bonusHandling;
  inline function get_maxSpeed() return ref.max_speed + bonusSpeed;
  inline function get_hpPool() return ref.base_hp;
  inline function get_handlingRange() return ref.handling - ref.handling_ratio;
  inline function get_friction() return ref.friction;
  inline function get_driftBonus() return ref.drift_bonus;
  
}