package ld45;

class Const {
  
  // public static var HEX_WIDTH:Float = 4.04285898182493;
  // public static var HEX_HEIGHT:Float = 4.66828701400458;
  public static inline var HEX_WIDTH:Float = 4.14285898182493;
  public static inline var HEX_HEIGHT:Float = 4.76828701400458;
  public static inline var HEX_SIDE:Float = HEX_HEIGHT / 2; 
  
  public static inline var HEX_TOP:Float = 2.33413696289063;
  
  public static inline var HEX_HW:Float = HEX_WIDTH / 2;
  public static inline var HEX_V_STEP:Float = (HEX_HEIGHT + HEX_SIDE) / 2;
  public static inline var HEX_ODD:Bool = true;
  
  static inline var SQRT_3:Float = 1.73205080757;
  public static inline var LAY_F0:Float = SQRT_3;
  public static inline var LAY_F1:Float = SQRT_3 / 2;
  public static inline var LAY_F2:Float = 0;
  public static inline var LAY_F3:Float = 3 / 2;
  public static inline var LAY_B0:Float = SQRT_3 / 3;
  public static inline var LAY_B1:Float = -1 / 3;
  public static inline var LAY_B2:Float = 0;
  public static inline var LAY_B3:Float = 2 / 3;
  
  public static inline var MAP_W:Int = 5;
  public static inline var MAP_H:Int = 8;
  
  public static inline var CAMP_TIP:String = "Camp here to harvest resources<br/>and trigger events from all adjacent tiles";
  public static inline var CAMP_NOPE:String = "<br/><font color='#aaaaaa'>(you don't have enough tools to set up a camp)</font>";
  
  public static inline var START:String = " In this chilly, desolate, ravaged land you have nothing. Nothing and noone but yourself. But there are people waiting for you at home in the faraway snowy forests.\n\nYou decide to gather some resources before you start your journey. This nearby village must have something of value at least.";
  public static inline var FINAL_TIP:String = " The goal is near! You remember your hometown neatly hidden in a circle of crimson forests, surrounded by a moat. You can already see it in the distance!";
  public static inline var VICTORY:String = " Victory! You arrive home safe and sound, leaving all the dangers behind. The people smile at you warmly. You won't ever be left with nothing again.\n\nBut then again, maybe you wish to begin you journey anew?";
  public static inline var FAIL:String = " You can't go on any longer. Before you close your eyes, a single thought crosses your mind: just one more try, you should be okay after a short rest.\nWould you like to restart now?";
}