package comps;

import hxd.Key;
import h2d.RenderContext;
import h2d.Layers;
import State;
import h2d.Flow;
import h2d.Object;

class GameUI extends Layers {
  
  #if debug
  var ov:h2d.ui.DevUI;
  #end
  
  public var text:TextView;
  var wait:WaitButton;
  var scavenge:LButton;
  
  public function new(parent:Layers) {
    super();
    parent.add(this, 3);
    var btn = new TopButton(false, R.xsub(171, 19, 17, 8, 2, 1, 7, 2), this);
    btn.onClick = (_) -> {
      if (Main.evo == null || Main.evo.destroyed) Main.evo = new EvoMenu();
    }
    
    btn = new TopButton(true, R.xsub(207, 19, 24, 8, 2, 1, 19, 2), this);
    btn.x = R.W - btn.width;
    btn.onClick = (_) -> {
      if (Main.menu == null || Main.menu.destroyed) Main.menu = new MainMenu();
    }
    
    new StepCounter(this);
    
    text = new TextView(this);
    text.setPosition(86, 138);
    Main.game.delayer.addF("turn", () -> State.i.triggerText("turn", true), 1);
    
    var left = new Flow(this);
    left.layout = Vertical;
    left.verticalSpacing = 2;
    left.setPosition(4, 113);
    new StatView(StatName.Health, 0, left);
    new StatView(StatName.Hunger, 1, left);
    new StatView(StatName.Humanity, 2, left);
    left.addSpacing(2);
    scavenge = new LButton([
      R.xsub(0, 0, 56, 15, 3),
      R.xsub(171, 1, 41, 8, 2, 1, 7, 3)
    ], left);
    Button.shiftDown = false;
    scavenge.addFlags(Disabled, [
      R.xsub(255, 1, 56, 14, 1),
      R.xsub(171, 1, 41, 8, 2, 1, 7, 3)
    ]);
    Button.shiftDown = true;
    var scavengett = new Tooltip("", this);
    scavenge.onOver = (_) -> {
      var can = State.i.canScavenge();
      if (can) {
        State.i.projected = State.i.config.costs.scavenge;
      }
      
      if (State.i.stage == 0) scavengett.updateText("I have enough resourses for now");
      else if (!can) scavengett.updateText("I should stay, the morphling might evolve soon");
      else scavengett.updateText("Leave the base to gather resources. Make sure the morphling is fed!");
      scavengett.show();
    }
    scavenge.onOut = (_) -> {
      State.i.projected = 0;
      scavengett.hide();
    }
    scavenge.onClick = (_) -> if (State.i.canScavenge()) {
      State.i.advance(State.i.config.costs.scavenge);
      if (Main.scav == null || Main.scav.destroyed) Main.scav = new ScavengeMenu();
    }
    
    new ActionButton(0, Veggies, this);
    new ActionButton(1, Cloth, this);
    new ActionButton(2, Meat, this);
    new ActionButton(3, Armor, this);
    new ActionButton(4, Toy, this);
    new ActionButton(5, Medicine, this);
    wait = new WaitButton(this);
    wait.setPosition(259, 114);
    check();
    #if debug
    // ov = new h2d.ui.DevOverlay(this);
    ov = new h2d.ui.DevUI(this);
    ov.autoWatch = true;
    ov.beginGroup("Stats");
    ov.stat( () -> State.i.evo, "evolution" );
    ov.stat( () -> State.i.step + " / " + State.i.stage, "step" );
    ov.statF( () -> State.i.stats[Health], "health" );
    ov.statF( () -> State.i.stats[Hunger], "hunger" );
    ov.statF( () -> State.i.stats[Humanity], "humanity" );
    ov.endGroup();
    ov.beginGroup("Flags");
    ov.statI( () -> State.i.flags.get(Sick), "sick");
    ov.statI( () -> State.i.flags.get(Unhappy), "unhappy");
    ov.statI( () -> State.i.flags.get(Hungry), "hungry");
    ov.statI( () -> State.i.flags.get(Evil), "evil");
    ov.statI( () -> State.i.flags.get(Good), "good");
    ov.statI( () -> State.i.flags.get(Dying), "dying");
    ov.statI( () -> State.i.flags.get(Unsafe), "unsafe");
    ov.statI( () -> State.i.flags.get(LongHunger), "long_hunger");
    ov.statI( () -> State.i.flags.get(LongUnhappy), "long_unhappy");
    ov.statI( () -> State.i.flags.get(Lonely), "lonley");
    ov.statI( () -> State.i.flags.get(Veggies), "veggies");
    ov.statI( () -> State.i.flags.get(Meat), "meat");
    ov.statI( () -> State.i.flags.get(Cloth), "cloth");
    ov.statI( () -> State.i.flags.get(Armor), "armor");
    ov.statI( () -> State.i.flags.get(Toy), "toy");
    ov.statI( () -> State.i.flags.get(Medicine), "medicine");
    ov.endGroup();
    ov.scale(1/3);
    ov.visible = false;
    #end
  }
  
  public function check() {
    var shouldWait = !State.i.canScavenge();
    scavenge.setFlag(Disabled, shouldWait);
    for (r in State.i.resources) if (r > 0) {
      shouldWait = false;
      break;
    }
    wait.visible = shouldWait;
  }
  
  override function sync(ctx:RenderContext)
  {
    #if debug
    if (Key.isReleased(Key.Q)) ov.visible = !ov.visible;
    #end
    super.sync(ctx);
  }
  
}