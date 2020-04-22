package game;

import util.DebugDisplay;
import hxd.Math;
import game.ai.RaceState;
import h2d.RenderContext;
import h2d.Mask;
import h2d.Bitmap;
import h2d.Tile;
import hxd.Res;
import h2d.Object;

class UI extends Object {
  
  var car:Car;
  var hpMask:Bitmap;
  var state:RaceState;
  
  var portraits:Array<Bitmap>;
  var faces:Array<Tile>;
  var cooldown:Array<Tile>;
  
  public function new(car:Car, state:RaceState, ?parent:Object)
  {
    this.state = state;
    this.car = car;
    super(parent);
    faces = Res.ui.faces.toTile().gridFlatten(154);
    // setScale(0.5);
    var atlas:Tile = Res.ui.ui.toTile();
    var drop = new Bitmap(atlas.sub(14, 141, 784, 370), this);
    drop.y = Const.IH - drop.tile.height * .8 - 4;
    drop.x = 14;
    drop.setScale(0.8);
    hpMask = new Bitmap(atlas.sub(29, 636, 746, 91), drop);//new Mask(746, 91, drop);
    final yy = 251;
    hpMask.setPosition(17, yy);
    
    
    new Bitmap(atlas.sub(29, 524, 746, 91), drop).setPosition(17, yy);
    new Bitmap(kToFace(car.stats.ref.name, false, 144), drop).setPosition(36, 28);
    
    new Bitmap(atlas.sub(0, 0, 1920, 52), this);
    
    portraits = new Array();
    var pp:Bitmap = null;
    for (s in state.cars)
    {
      var face = kToFace(s.stats.ref.name, false).clone();
      var bg = s == car ? atlas.sub(98, 74, 45, 43) : atlas.sub(38, 77, 38, 36);
      bg.setCenterRatio();
      var b = new Bitmap(bg, this);
      b.y = 29;
      if (s == car)
      {
         face.scaleToSize(32, 32);
         pp = b;
      }
      else face.scaleToSize(26, 26);
      face.setCenterRatio();
      new Bitmap(face, b);
      portraits.push(b);
    }
    
    cooldown = new Array();
    for (a in car.abilities)
    {
      var t = Res.load(a.ref.icon).toTile();
      t.scaleToSize(100, 100);
      t.setCenterRatio();
      var b = new Bitmap(t, drop);
      b.setPosition(300 + 128 * cooldown.length, 100);
      var b2 = new Bitmap(Tile.fromColor(0x571003, 101, 101, 0.3).center(), drop);
      b2.x = b.x;
      b2.y = b.y;
      b2.blendMode = Multiply;
      cooldown.push(b2.tile);
    }
    addChild(pp);
  }
  
  function kToFace(t:CarsKind, angery:Bool, ?size:Float)
  {
    var off = angery ? 4 : 0;
    var tile = switch (t)
    {
      case emo: faces[0+off];
      case stroker: faces[1+off];
      case rider: faces[2+off];
      default: faces[3+off];
    }
    if (size != null) 
    {
      tile = tile.clone();
      tile.scaleToSize(size, size);
    }
    return tile;
  }
  
  override private function sync(ctx:RenderContext)
  {
    var ratio = car.hp / car.stats.hpPool;
    hpMask.tile.setSize(Math.lerp(hpMask.tile.width, 103 + 631 * ratio, 0.2), hpMask.tile.height);
    for (i in 0...state.cars.length)
    {
      var c = state.cars[i];
      var p = portraits[i];
      p.x = Math.lerp(p.x, 54 + (1810 * (c.position / state.length + c.laps * state.length)) % 1810, 0.1);
    }
    for (i in 0...car.abilities.length)
    {
      var a = car.abilities[i];
      var t = cooldown[i];
      var v = 1 - a.cooldownVal();
      // DebugDisplay.info('$v', 10, 150 + 30 * i);
      t.scaleToSize(101, v * 101);
    }
    super.sync(ctx);
  }
  
}