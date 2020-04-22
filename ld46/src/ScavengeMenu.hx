import comps.TextView;
import comps.Tooltip;
import State;
import h2d.Tile;
import h2d.RenderContext;
import comps.Button;
import dn.M;
import haxe.Json;
import comps.LButton;
import comps.StepCounter;
import comps.TopButton;
import hxd.Res;
import h2d.Bitmap;
import h3d.pass.Default;
import h2d.Interactive;
import dn.Process;

class ScavengeMenu extends Process {
  
  var nodes:Array<MapNode>;
  var curr:MapNode;
  var turns:Int;
  var txt:TextView;
  var base:MapNode;
  
  override public function init()
  {
    super.init();
    createRoot(Main.i.s2d);
    var i = new Interactive(R.W, R.H, root);
    i.cursor = Default;
    
    var config:Array<ScavengeDef> = Json.parse(Res.scavenge.entry.getText());
    var map = config[M.rand(config.length)];
    new Bitmap(Res.load(map.file).toTile(), root);
    
    var base = map.base+1;
    var i = 0;
    var nodes:Array<MapNode> = [while (i < map.nodes.length) new MapNode(map.nodes[i++], map.nodes[i++], i>>1 == base, (i>>1)-1, root)];
    var base = nodes[base-1];
    i = 0;
    while (i < map.connections.length) {
      nodes[map.connections[i]].connect(nodes[map.connections[i+1]]);
      i += 2;
    }
    var pool:Array<Null<ActionName>> = [];
    for (i in 0...map.resources.armor) pool.push(Armor);
    for (i in 0...map.resources.cloth) pool.push(Cloth);
    for (i in 0...map.resources.veggies) pool.push(Veggies);
    for (i in 0...map.resources.meat) pool.push(Meat);
    for (i in 0...map.resources.toy) pool.push(Toy);
    for (i in 0...map.resources.medicine) pool.push(Medicine);
    while (pool.length < nodes.length-1) pool[pool.length] = null;
    for (n in nodes) {
      n.onClick = tryMoveTo.bind(_, n);
      if (n == base) continue; // Nothing on base
      if (pool.length != 0) {
        var idx = pool.splice(M.rand(pool.length), 1)[0];
        if (idx != null) n.setRes(idx);
      }
    }
    base.setFocus(true);
    this.base = base;
    this.nodes = nodes;
    curr = base;
    //#region UI
    new Bitmap(Res.scavenge_bg.toTile(), root);
    
    var btn = new TopButton(false, R.xsub(171, 19, 17, 8, 2, 1, 7, 2), root);
    btn.onClick = (_) -> {
      if (Main.evo == null || Main.evo.destroyed) Main.evo = new EvoMenu();
    }
    
    btn = new TopButton(true, R.xsub(207, 19, 24, 8, 2, 1, 19, 2), root);
    btn.x = R.W - btn.width;
    btn.onClick = (_) -> {
      if (Main.menu == null || Main.menu.destroyed) Main.menu = new MainMenu();
    }
    
    new StepCounter(root);
    
    var scavenge = new LButton([
      R.xsub(0, 0, 56, 15, 3),
      R.xsub(171, 10, 32, 8, 2, 1, 12, 3)
    ], root);
    scavenge.setPosition(4, 159);
    scavenge.onClick = (_) -> destroy();
    
    new comps.ResourceView(Veggies, true, root).setPosition(272, 158);
    new comps.ResourceView(Meat, true, root).setPosition(293, 158);
    new comps.ResourceView(Toy, true, root).setPosition(313, 158);
    new comps.ResourceView(Cloth, true, root).setPosition(272, 169);
    new comps.ResourceView(Armor, true, root).setPosition(293, 169);
    new comps.ResourceView(Medicine, true, root).setPosition(313, 169);
    function tt(r:ActionName, x, y) {
      var v = comps.Tooltip.makeInter("", 20, 10, root);
      v.inter.setPosition(x-14, y-1);
      Tooltip.bindResource(v.tooltip, r);
    }
    tt(Veggies, 272, 158);
    tt(Meat, 293, 158);
    tt(Toy, 313, 158);
    tt(Cloth, 272, 169);
    tt(Armor, 293, 169);
    tt(Medicine, 313, 169);
    
    turns = State.i.config.scavenge_turns;
    txt = new TextView(root);
    txt.setPosition(86, 150);
    
    var cnt = State.i.scavengeCount;
    var sel:Array<String> = [];
    var tag = State.i.flags.get(Evil) > 0 ? "bad mob" : State.i.flags.get(Good) > 0 ? "good mob" : "neutral mob";
    for (line in Res.texts.scavenge.entry.getText().split("\n")) {
      var spl = line.split("\t");
      var id = spl[0];
      if (cnt == 0 && id == "1st scavenge") { sel.push(spl[1]); break; }
      if (cnt == 1 && id == "2nd scavenge") { sel.push(spl[1]); break; }
      if (id == "random scavenge" || id == tag) sel.push(spl[1]);
    }
    txt.show(sel[dn.M.rand(sel.length)]);
    
    State.i.scavengeCount++;
    //#endregion
  }
  
  function tryMoveTo(_, node:MapNode) {
    if (turns == 0) return;
    if (curr.conn.indexOf(node) != -1) {
      curr.setFocus(false);
      curr = node;
      node.setFocus(true);
      turns--;
      if (turns == 0) {
        if (curr == base) txt.show("Out of fuel, the scavenge is over for now.");
        txt.show("I should return, my fuel levels are depleted.");
      } else {
        txt.show('Enough fuel to visit ${turns} more location' + (turns != 1 ? "s." : "."));
      }
    }
  }
  
}

class MapNode extends Button {
  
  public var conn:Array<MapNode>;
  var focused:Tile;
  var resTile:Tile;
  var res:ActionName;
  var rnd:Float;
  var glow:Bitmap;
  
  public function new(x:Int, y:Int, isBase:Bool, idx:Int, ?parent) {
    // var s = isBase ? 20 : 12;
    conn = [];
    rnd = Math.random() * 30;
    Button.shiftDown = false;
    super(isBase ? R.xsub(209, 91, 20, 20, 2) : R.xsub(209, 112, 12, 12, 2), parent);
    focused = isBase ? R.a.sub(251, 91, 20, 20) : R.a.sub(235, 112, 12, 12);
    Button.shiftDown = true;
    glow = R.glow(16, 16, 0x7788dd, this);
    glow.alpha = 0;
    glow.setPosition(width*.5, height*.5);
    setPosition(x, y);
    // DEBUG
    // backgroundColor = 0xffff0000;
    // var txt = new h2d.Text(R.font, this);
    // txt.x = width;
    // txt.y = -5;
    // txt.text = idx+"";
  }
  
  static final nameIndex:Map<ActionName, Int> = [
    Veggies => 0, Cloth => 1, Meat => 2, Armor => 3, Toy => 4, Medicine => 5
  ];
  
  public function setRes(res:ActionName) {
    this.res = res;
    resTile = R.a.sub(188 + 11 * nameIndex[res], 30, 10, 9, 1, -13);
  }
  
  public function setFocus(b:Bool) {
    if (b) {
      // collect
      if (res != null) {
        State.i.resources[res] += State.i.config.scavenge_amount;
        res = null;
        resTile = null;
      }
    }
    setFlag(Focused, b);
  }
  
  override function sync(ctx:RenderContext)
  {
    if (flags.has(Focused)) {
      if (glow.alpha < 1) {
        glow.alpha += hxd.Timer.dt * 4;
        if (glow.alpha > 1) glow.alpha = 1;
      }
    } else if (glow.alpha > 0) {
      glow.alpha -= hxd.Timer.dt * 4;
      if (glow.alpha < 0) glow.alpha = 0;
    }
    if (resTile != null) {
      resTile.dy = -8 + Math.cos(hxd.Timer.lastTimeStamp+rnd) * 2;
    }
    super.sync(ctx);
  }
  
  override function draw(ctx:RenderContext)
  {
    if (flags.has(Focused)) {
      emitTile(ctx, focused);
    } else {
      super.draw(ctx);
      if (resTile != null) {
        emitTile(ctx, resTile);
      }
    }
  }
  
  public function connect(other:MapNode) {
    conn.push(other);
    other.conn.push(this);
    // var g = new h2d.Graphics(parent);
    // g.lineStyle(1, 0xffff0000);
    // g.moveTo(other.x + other.width * .5, other.y + other.height * .5);
    // g.lineTo(x + width * .5, y + height * .5);
  }
  
}

typedef ScavengeDef = {
  var file:String;
  var nodes:Array<Int>;
  var connections:Array<Int>;
  var base:Int;
  var resources: {
    veggies:Int, meat:Int, cloth:Int, armor:Int, medicine:Int, toy:Int
  };
}