import game.Car;
import hxd.Key;
import util.Input;

class LD {
  
  public static var forward:InputAction = new InputAction([Key.W, Key.UP]);
  public static var left:InputAction = new InputAction([Key.A, Key.LEFT]);
  public static var right:InputAction = new InputAction([Key.D, Key.RIGHT]);
  public static var back:InputAction = new InputAction([Key.S, Key.DOWN]);
  public static var drift:InputAction = new InputAction([Key.SPACE, Key.NUMPAD_0]);
  public static var ability_a:InputAction = new InputAction([Key.NUMBER_1, Key.NUMPAD_1]);
  public static var ability_b:InputAction = new InputAction([Key.NUMBER_2, Key.NUMPAD_2]);
  public static var ability_c:InputAction = new InputAction([Key.NUMBER_3, Key.NUMPAD_3]);
  public static var ability_d:InputAction = new InputAction([Key.NUMBER_4, Key.NUMPAD_4]);
  
  public static var abilities:Array<SkillsKind> = [
    blood_droplet, bloodnana, cherry_soup, blood_potion, lucky_bone, friendly_skull, party_bomb, bouncy, teddy, mushy, sparkly, overdose, hyper_armor
  ];
  
  public static var roster = [
    { map: "test.tmx", layer: 0 },
    { map: "tilemap_01.tmx", layer: 0 },
    { map: "tilemap_01.tmx", layer: 1 },
    { map: "tilemap_02.tmx", layer: 0 },
    { map: "tilemap_02.tmx", layer: 1 },
    { map: "tilemap_02.tmx", layer: 2 },
    { map: "tilemap_02.tmx", layer: 3 },
    { map: "tilemap_02.tmx", layer: 4 },
  ];
  
  public static var char:Cars;
  public static var sel:Array<Skills>;
  
}