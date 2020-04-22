import State;
import h3d.shader.UVScroll;
import h2d.Tile;
import h3d.mat.Texture;
import dn.M;
import hxd.Key;
import hxd.Res;
import h2d.Bitmap;
import dn.Process;

import comps.*;

class Game extends Process {
  
  public var pet:Pet;
  public var ui:GameUI;
  public var fog:Fog;
  
  public function new(startingEvo:Evolution = Evolution.EvoBase) {
    if (Main.game != null) {
      Main.game.destroy();
      Main.game = null;
    }
    State.i = new State(startingEvo);
    hxd.Music.play(Res.load("sound/" + State.i.currEvo().music).toSound());
    Main.game = this;
    super();
  }
  
  public static function restart() {
    new Game();
  }
  
  override public function init()
  {
    super.init();
    createRoot(Main.i.s2d);
    root.addChild(new Bitmap(Res.bg.toTile()));
    fog = new Fog(root);
    root.add(new Bitmap(Res.bg_front.toTile()), 3);
    
    pet = new Pet(State.i.currEvo(), root);
    ui = new GameUI(root);
  }
  
  override public function update()
  {
    #if debug
    if (Key.isReleased(Key.R)) {
      State.i.resources.set(Veggies, 99);
      State.i.resources.set(Meat, 99);
      State.i.resources.set(Cloth, 99);
      State.i.resources.set(Armor, 99);
      State.i.resources.set(Toy, 99);
      State.i.resources.set(Medicine, 99);
    }
    if (Key.isReleased(Key.T)) {
      State.i.step++;
    } else if (Key.isReleased(Key.Y)) {
      State.i.step--;
    }
    if (Key.isReleased(Key.Z)) @:privateAccess State.i.gameover("death_larva");
    if (Key.isReleased(Key.X)) @:privateAccess State.i.gameover("death");
    if (Key.isReleased(Key.C)) @:privateAccess State.i.gameover("escape");
    if (Key.isReleased(Key.V)) @:privateAccess State.i.gameover("evo_fail");
    if (Key.isReleased(Key.B)) new EndingScreen();
    #end
    super.update();
  }
  
}