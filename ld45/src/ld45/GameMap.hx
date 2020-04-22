package ld45;

import ld45.State;
import h3d.scene.World;
import ld45.HexTile;
import haxe.ds.HashMap;
import hxd.Res;
import Util;
import h3d.scene.Object;

class GameMap extends Object {
  
  public static var current:GameMap;
  public var player:Player;
  public var selection:TileSelection;
  public var tileInfo:TileInfo;
  public var event:EventWindow;
  var grid:Map<String, Array<HexTile>>;
  var gridContainers:Map<String, Object>;
  
  var easyPool:Array<String>;
  var normalPool:Array<String>;
  var hardPool:Array<String>;
  var lastGenerated:Bool = false;
  
  public function new(?parent)
  {
    super(parent);
    tileInfo = new TileInfo(Main.instance.s2d);
    event = new EventWindow(Main.instance.s2d);
    tileInfo.hide();
    selection = new TileSelection(this);
    player = new Player(this, 0, 0);
    current = this;
    grid = new Map();
    gridContainers = new Map();
    easyPool = State.config.pool.easy.copy();
    normalPool = State.config.pool.normal.copy();
    hardPool = State.config.pool.hard.copy();
  }
  
  override function onAdd()
  {
    super.onAdd();
  }
  
  public function nearby(pos:HexCoord, includeSame:Bool):Array<HexTile>
  {
    var t = findTile(pos);
    if (t != null) return t.neighbors;
    return [];
  }
  
  public function spawnTile(coord:HexCoord, type:TileType, edge:EdgeDir)
  {
    var gx = coord.cx, gy = coord.cy;
    var hash = posHash(gx, gy);
    var cluster = grid.get(hash);
    var tile = new HexTile(gridContainers[hash], coord.x, coord.y, type);
    tile.edge = edge;
    inline function scan(tiles:Array<HexTile>)
    {
      if (tiles != null)
      for (t in tiles)
      {
        if (t.pos.isNeighbor(tile.pos))
        {
          t.neighbors.push(tile);
          tile.neighbors.push(t);
        }
      }
    }
    scan(cluster);
    cluster.push(tile);
    switch(edge)
    {
      case Left:
        scan(grid.get(posHash(gx-1, gy)));
      case Right:
        scan(grid.get(posHash(gx+1, gy)));
      case Up:
        scan(grid.get(posHash(gx, gy-1)));
      case Down:
        scan(grid.get(posHash(gx, gy+1)));
      case TopLeft:
        scan(grid.get(posHash(gx, gy-1)));
        scan(grid.get(posHash(gx-1, gy)));
        scan(grid.get(posHash(gx-1, gy-1)));
      case TopRight:
        scan(grid.get(posHash(gx, gy-1)));
        scan(grid.get(posHash(gx+1, gy)));
        scan(grid.get(posHash(gx+1, gy-1)));
      case BottomLeft:
        scan(grid.get(posHash(gx, gy+1)));
        scan(grid.get(posHash(gx-1, gy)));
        scan(grid.get(posHash(gx-1, gy+1)));
      case BottomRight:
        scan(grid.get(posHash(gx, gy+1)));
        scan(grid.get(posHash(gx+1, gy)));
        scan(grid.get(posHash(gx+1, gy+1)));
      case None: // none
    }
    return tile;
  }
  
  public function findTile(pos:HexCoord):HexTile
  {
    var tiles = getCluster(pos);
    if (tiles == null) return null;
    for (t in tiles) if (t.pos.q == pos.q && t.pos.r == pos.r) return t;
    return null;
  }
  
  function getCluster(pos:HexCoord)
  {
    return this.grid.get(posHash(pos.cx, pos.cy));
  }
  
  function posHash(x:Int, y:Int)
  {
    return '$x-$y';
    // if (x < 0) x = 0xffff - x+1;
    // if (y < 0) y = 0xffff - y+1;
    // return x << 16 | y;
  }
  
  public function load(mapName:String, gx:Int, gy:Int, first:Bool = false, eventCount:Int = 2)
  {
    var tmx = Res.load("maps/" + mapName + ".tmx").to(hxd.res.TiledMapFile);
    var data = tmx.toMap(true, false);
    var map = data.tmx;
    var w = map.width;
    var h = map.height;
    var c = new HexCoord();
    var tiles = new Array<HexTile>();
    var hash = posHash(gx, gy);
    gridContainers.set(hash, new Object(this));
    grid.set(hash, tiles);
    var baseX = gx * Const.MAP_W;
    var baseY = gy * Const.MAP_H;
    // c.setOffset(gx * Const.MAP_W, gy * Const.MAP_H);
    var tmp = new HexCoord();
    var types:Map<Int, TileType> = [];
    for (t in map.tilesets[0].tiles)
    {
      if (t.properties.exists("type"))
      {
        types.set(t.id+1, TileType.createByName(t.properties.get("type")));
      }
    }
    for (l in map.layers)
    {
      switch(l)
      {
        case LTileLayer(layer):
          var y = 0, x = 0, edge:EdgeDir;
          for (t in layer.data.tiles)
          {
            if (t.gid != 0)
            {
              edge = if (y == 0) {
                if (x == 0) TopLeft;
                else if (x == w - 1) TopRight;
                else Up;
              } else if (y == h - 1) {
                if (x == 0) BottomLeft;
                else if (x == w - 1) BottomRight;
                else Down;
              } else if (x == 0) Left;
              else if (x == w - 1) Right;
              else None;
              
              tmp.setOffset(x+baseX, y+baseY);
              tmp.addSelf(c.q, c.r, c.s);
              spawnTile(tmp, types[t.gid], edge);
              if (first && types[t.gid] == House)
              {
                player.setHexPos(tmp.q, tmp.r, tmp.s);
                first = false;
              }
            }
            if (++x == w) { x = 0; y++; }
          }
        default:
      }
    }
    var cnt = tiles.length;
    while (eventCount > 0 && cnt > 0)
    {
      var t = tiles[Std.int(Math.random() * tiles.length)];
      cnt--;
      if (t.pos.equals(player.pos)) continue;
      var tinfo:TileBalance = Reflect.field(State.config.tiles, t.type.getName());
      if (tinfo.events == null || tinfo.events.length == 0) continue;
      t.quest = 1;
      t.updateIcon();
      eventCount--;
    }
    if (mapName == State.config.pool.last)
    {
      tmp.setOffset(baseX + 1 , baseY + 3);
      tmp.addSelf(c.q, c.r, c.s);
      var t = findTile(tmp); t.quest = 10; t.updateIcon();
      tmp.setOffset(baseX + 2 , baseY + 3);
      tmp.addSelf(c.q, c.r, c.s);
      t = findTile(tmp); t.quest = 10; t.updateIcon();
      tmp.setOffset(baseX + 2 , baseY + 4);
      tmp.addSelf(c.q, c.r, c.s);
      t = findTile(tmp); t.quest = 10; t.updateIcon();
      tmp.setOffset(baseX + 3 , baseY + 4);
      tmp.addSelf(c.q, c.r, c.s);
      t = findTile(tmp); t.quest = 10; t.updateIcon();
    }
    if (lastGenerated)
    {
      for (t in tiles)
      {
        t.resource = -1;
        t.updateIcon();
      }
    }
  }
  
  public function expand(coord:HexCoord, edge:EdgeDir)
  {
    var gx = coord.cx, gy = coord.cy;
    switch (edge)
    {
      case Left:
        gx--;
      case Right:
        gx++;
      case Up:
        gy--;
      case Down:
        gy++;
      default: return; // meh
    }
    var tiles = grid.get(posHash(gx, gy));
    if (tiles == null)
    {
      var quests:Int = 2;
      var dist = Math.sqrt(gx*gx+gy*gy);
      var map:String = State.config.pool.first;
      
      if (lastGenerated)
      {
        map = "hex-final-fill";
        quests = 0;
      }
      else if (dist < 1) map = "hex-final-fill";
      else if (dist <= State.config.pool.dist_easy)
      {
        var idx = Std.int(Math.random() * easyPool.length);
        map = easyPool[idx];
        if (easyPool.length == 1) easyPool = State.config.pool.easy.copy();
        else easyPool.splice(idx,1);
      }
      else if (dist <= State.config.pool.dist_normal)
      {
        var idx = Std.int(Math.random() * normalPool.length);
        map = normalPool[idx];
        if (normalPool.length == 1) normalPool = State.config.pool.normal.copy();
        else normalPool.splice(idx,1);
      }
      else if (dist <= State.config.pool.dist_hard)
      {
        var idx = Std.int(Math.random() * hardPool.length);
        map = hardPool[idx];
        if (hardPool.length == 1) hardPool = State.config.pool.hard.copy();
        else hardPool.splice(idx,1);
      }
      else 
      {
        if (lastGenerated) return;
        lastGenerated = true;
        map = State.config.pool.last;
        quests = 0;
        event.showCustom(Const.FINAL_TIP, function():Void {}, null);
      }
      // trace('spawn: $map | tile: [${coord.x}, ${coord.y}/${coord.cx}, ${coord.cy}] cluster: [$gx, $gy], edge: $edge');
      load(map, gx, gy, false, quests);
    }
    else 
    {
      
    }
  }
  
  // public function fill(ox:Int, oy:Int, w:Int, h:Int, type:TileType)
  // {
    
  //   for (y in 0...h)
  //   {
  //     for (x in 0...w)
  //     {
  //       spawnTile(x+ox, y+oy, type);
  //     }
  //   }
    
  // }
  
  public function start()
  {
    Main.syncUpdate();
    findTile(player.pos).resetResource();
    // player.step();
    step();
  }
  
  public function step()
  {
    for (o in @:privateAccess Main.toUpdate)
    {
      o.step();
    }
    var gx = player.pos.cx - 3, gy = player.pos.cy - 3;
    // for (t in grid.get(posHash(gx, gy))) t.check();
    inline function check(x:Int, y:Int)
    {
      var g = grid.get(posHash(x, y));
      if (g != null) for (t in g) t.check();
    }
    for (y in 0...7)
    {
      for (x in 0...7)
      {
        var hash = posHash(gx + x, gy + y);
        var cont = gridContainers[hash];
        if (cont == null) continue;
        if (x == 0 || x == 6 || y == 0 || y == 6)
        {
          if (cont.parent != null) cont.remove();
        }
        else 
        {
          if (cont.parent == null) addChild(cont);
          var g = grid.get(hash);
          for (t in g) t.check();
        }
      }
    }
    // check(gx-1, gy);
    // check(gx-1, gy-1);
    // check(gx-1, gy+1);
    // check(gx+1, gy);
    // check(gx+1, gy-1);
    // check(gx+1, gy+1);
    // check(gx, gy-1);
    // check(gx, gy+1);
  }
  
}