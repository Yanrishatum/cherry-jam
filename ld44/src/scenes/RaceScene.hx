package scenes;

import hxd.Timer;
import game.UpdateObject;
import game.ai.RaceState;
import h2d.Layers;
import hxd.Key;
import h2d.Bitmap;
import hxd.res.Resource;
import game.Physics;
import util.DebugDisplay;
import game.*;
import h2d.Object;
import h2d.RenderContext;
import hxd.res.TiledMapFile;
import h2d.Scene;
import game.abilities.*;

class RaceScene extends Scene implements IUpdateObject {
  
  var container:Layers;
  var track:Track;
  var player:Car;
  var race:RaceState;
  var ts:Float;
  
  public function new(map:Resource, layer:Int)
  {
    super();
    race = new RaceState();
    defaultSmooth = true;
    container = new Layers(this);
    track = new Track(map, layer, container);
		player = new game.Car(LD.char, true);
    for (s in LD.sel)
    {
      player.hp = player.hpMax -= s.price * player.stats.hpPool;
      switch(s.id)
      {
        case blood_droplet, bloodnana, cherry_soup, blood_potion:
          player.abilities.push(new Healing(s));
        case lucky_bone:
          player.abilities.push(new LuckyBone());
        case friendly_skull:
          player.abilities.push(new Skull());
        case party_bomb:
          player.abilities.push(new PartyBomb());
        case bouncy:
          player.abilities.push(new Bouncy());
        case teddy:
          player.abilities.push(new Teddy());
        case mushy:
          player.abilities.push(new Mushy());
        case sparkly:
          player.abilities.push(new Sparkly());
        default: 
          player.abilities.push(new LuckyBone());
      }
    }
    // player.abilities.push(new Healing(Data.skills.get(cherry_soup)));
    switch(LD.char.name)
    {
      case emo:
        player.abilities.push(new Overdose());
        player.abilities.push(new Sword());
      case stroker:
        player.abilities.push(new Overdose());
        player.abilities.push(new HighStakes());
      case rider:
        player.abilities.push(new Overdose());
        player.abilities.push(new Stampede());
      case booty:
        player.abilities.push(new Overdose());
        player.abilities.push(new Akbar());
    }
    // player.abilities.push(new Overdose());
    // player.abilities.push(new LuckyBone());
    // player.abilities.push(new PartyBomb());
    // // player.abilities.push(new Teddy());
    // player.abilities.push(new Bouncy());
    
    race.setRoute(track.route, track.startDir.angle);
    var list = [
      player,
      new Car(Data.cars.get(CarsKind.emo), false),
      new Car(Data.cars.get(CarsKind.rider), false),
      new Car(Data.cars.get(CarsKind.stroker), false),
      new Car(Data.cars.get(CarsKind.booty), false),
      new Car(Data.cars.get(CarsKind.rider), false),
      new Car(Data.cars.get(CarsKind.stroker), false),
      new Car(Data.cars.get(CarsKind.booty), false),
    ];
    var i = 0;
    while (list.length > 0)
      addCar(list.splice(Std.int(Math.random() * list.length), 1)[0], i++);
    
    setFixedSize(1920, 1080);
    // container.scale(0.5);
    player.syncShape();
    container.originX = -(width>>1);
    container.originY = -(height>>1);
    syncZoom(1);
    new UI(player, race, this);
    // container.x = cameraTX();
    // container.y = cameraTY();
    
  }
  
  function addCar(car:Car, place:Int)
  {
    var sx = track.startX * Const.TILE_SIZE + Const.TILE_SIZE * .5;
    var sy = track.startY * Const.TILE_SIZE + Const.TILE_SIZE * .5;
    var angle = track.startDir.angle + Math.PI * .5;
    if (place > 0)
    {
      var offX = -Const.TILE_SIZE * .12 + Const.TILE_SIZE * .24 * ((place + 1) % 2);
      var offY = Math.ceil(place / 2) * Const.TILE_SIZE * .12;
      var sin = Math.sin(angle);
      var cos = Math.cos(angle);
      trace(offX, offY);
      sx += offX * cos + offY * -sin;
      sy += offX * sin + offY * cos;
    }
    car.shape.set(sx, sy);
    car.setAngle(track.startDir.angle);
    container.addChildAt(car.trails, 1);
		container.addChildAt(car, 2);
    race.addCar(car);
    car.syncShape();
  }
  
  public function debug_changeCar(car:Cars)
  {
    @:privateAccess player.stats.ref = car;
    var img = hxd.Res.load(car.image).toTile().center();
    player.removeChildren();
    @:privateAccess player.shadow = Util.makeShadow(img, player);
    @:privateAccess player.car = new Bitmap(img, player);
  }
  
  override private function onAdd()
  {
    DebugDisplay.attach(this);
    Main.updateList.push(this);
    ts = Timer.lastTimeStamp + 3;
    super.onAdd();
  }
  
  override private function onRemove()
  {
    Main.updateList.remove(this);
    super.onRemove();
  }
  
  public function update()
  {
    if (race.started)
      race.update();
    else if (ts < Timer.lastTimeStamp) race.started = true;
  }
  
  override private function sync(ctx:RenderContext)
  {
    // #if debug
    // if (Key.isPressed(Key.QWERTY_MINUS)) container.setScale(0.25);
    // else if (Key.isPressed(Key.QWERTY_EQUALS)) container.setScale(0.5);
    // #end
    // Physics.instance.draw(container);
    
    syncZoom();
    super.sync(ctx);
    
  }
  
  function syncZoom(lerp:Float = 0.1)
  {
    var zoom = SPEED_ZOOM_DEF;
    if (player.velocity != 0)
    {
      inline function quadInOut(t:Float):Float
      {
        return t;
        //return t <= .5 ? t * t * 2 : 1 - (--t) * t * 2;
      }
      zoom -= SPEED_ZOOM * quadInOut(Math.abs(player.velocity) / Const.SPEED_CONSTANT);
    }
    var ctx = cameraTX();
    var cty = cameraTY();
    var newZoom = hxd.Math.lerp(container.scaleX, zoom, lerp);
    container.setScale(newZoom);
    // // container.scaleX = newZoom;
    // container.x -= (width) * (change);
    // container.y -= (height) * (change);
    var nctx = cameraTX();
    var ncty = cameraTY();
    container.x += nctx - ctx;
    container.y += ncty - cty;
    // DebugDisplay.info('Zoom: $newZoom\nX: ${container.x}\nY: ${container.y}\nTX: ${ctx}\nTY: ${cty}\nNTX: ${nctx}\nNTY: ${ncty}', 150, 150);
    
    container.x = hxd.Math.lerp(container.x, nctx, lerp);
    container.y = hxd.Math.lerp(container.y, ncty, lerp);
    // container.x = hxd.Math.lerp(container.x, cameraTX(), 1);
    // container.y = hxd.Math.lerp(container.y, cameraTY(), 1);
  }
  
  // inline static var SPEED_ZOOM_DEF = 1.0;
  inline static var SPEED_ZOOM_DEF = 1.0;
  inline static var SPEED_ZOOM = 0.6;
  
  inline static var VELOCITY_DAMP = 0.35;
  inline function cameraTX()
  {
    return -(player.x + player.velocity * Math.cos(player.carAngle) * VELOCITY_DAMP) * container.scaleX;
  }
  
  inline function cameraTY()
  {
    return -(player.y + player.velocity * Math.sin(player.carAngle) * VELOCITY_DAMP) * container.scaleY;
  }
  
}