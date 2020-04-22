package game;

import h2d.Layers;
import h2d.Graphics;
import util.DebugDisplay;
import h2d.RenderContext;
import h2d.Bitmap;
import hxd.res.Resource;
import format.tmx.Data;
import hxd.Direction;
import haxe.io.Path;
import differ.math.Vector;
import differ.shapes.Polygon;
import format.tmx.Tools;
import format.tmx.Reader;
import hxd.res.TiledMapFile;
import h2d.Object;

class Track extends Object {
  
  var segments:Array<TrackSegment>;
  public var startX:Int;
  public var startY:Int;
  public var startDir:Direction;
  public var route:Array<Vector>;
  
  public function new(map:Resource, layerId:Int, ?parent:Layers)
  {
    super(parent);
    startDir = Up;
    segments = new Array();
    route = new Array();
    var routeSegments:Array<Array<Vector>> = new Array();
    var reader = new Reader();
    reader.resolveTSX = function(file:String) {
      return reader.readTSX(Xml.parse(hxd.Res.load("maps/" + Path.withoutDirectory(file)).entry.getText()));
    }
    var tmx = reader.read(Xml.parse(map.entry.getText()));
    var lidx = 0;
    for (l in tmx.layers)
    {
      switch (l)
      {
        case LTileLayer(layer):
          if (lidx++ != layerId) continue;
          var y = 0, x = 0;
          for (t in layer.data.tiles)
          {
            if (t.gid != 0)
            {
              var tset = Tools.getTilesetByGid(tmx, t.gid);
              var scale = Const.TILE_SIZE / tset.tileWidth;
              if (tset != null)
              {
                var tinfo:TmxTilesetTile = null;
                var lid = t.gid - tset.firstGID;
                for (ti in tset.tiles) {
                  if (ti.id == lid)
                  {
                    tinfo = ti;
                    break;
                  }
                }
                
                if (tinfo != null && tinfo.objectGroup != null)
                {
                  var ox = x * Const.TILE_SIZE;
                  var oy = y * Const.TILE_SIZE;
                  var polys:Map<Int, Array<Polygon>> = new Map();
                  for (obj in tinfo.objectGroup.objects)
                  {
                    var z = 0;
                    switch(obj.objectType)
                    {
                      case OTPolygon(points):
                        if (obj.properties.exists("z")) z = obj.properties.getInt("z");
                        var sum = 0.;
                        var p1 = points[points.length - 1];
                        for (p2 in points)
                        {
                           sum += (p2.x - p1.x) * (p2.y + p1.y);
                           p1 = p2;
                        }
                        if (sum > 0) points.reverse();
                        
                        var poly = new Polygon(0, 0, [for (p in points) new Vector(obj.x * scale + ox + p.x * scale, obj.y * scale + oy + p.y * scale)]);
                        if (obj.type == "trigger")
                        {
                          new RouteTrigger(poly, this, obj.properties);
                        }
                        else
                        {
                          var arr = polys.get(z);
                          if (arr == null) arr = polys[z] = new Array();
                          arr.push(poly);
                        }
                      case OTPolyline(points):
                        var line = [for (p in points) new Vector(obj.x * scale + ox + p.x * scale, obj.y * scale + oy + p.y * scale)];
                        routeSegments.push(line);
                      default:
                    }
                  }
                  segments.push( new TrackSegment(this, x, y, polys));
                  if (tinfo.properties.exists("start") && tinfo.properties.getBool("start"))
                  {
                    startX = x;
                    startY = y;
                    startDir = @:privateAccess cast Direction.VALUES.indexOf(tinfo.properties.get("dir"));
                  }
                  if (tinfo.properties.exists("tile"))
                  {
                    var t = hxd.Res.load("maps/" + tinfo.properties.get("tile")).toTile().center();
                    t.dx = tinfo.properties.getFloat("ox") * Const.MAP_SCALE;
                    t.dy = tinfo.properties.getFloat("oy") * Const.MAP_SCALE;
                    var b = new Bitmap(t, this);
                    b.setPosition(x * Const.TILE_SIZE, y * Const.TILE_SIZE);
                    b.scale(2);
                    b.rotation = hxd.Math.degToRad(tinfo.properties.getFloat("rotation"));
                    if (tinfo.properties.exists("tile_top"))
                    {
                      var t2 = hxd.Res.load("maps/" + tinfo.properties.get("tile_top")).toTile().center();
                      t2.dx = t.dx;
                      t2.dy = t.dy;
                      var b2 = new Bitmap(t2);
                      b2.smooth = true;
                      parent.addChildAt(b2, 3);
                      b2.rotation = b.rotation;
                      b2.setPosition(b.x, b.y);
                      b2.scale(2);
                    }
                  }
                }
              }
            }
            if (++x == tmx.width) { x = 0; y++; }
          }
          for (i in 0...100)
          {
            var data = layer.properties.get("image." + i);
            if (data == null) break;
            var info = data.split(";");
            var t = hxd.Res.load("maps/" + info[0]).toTile();
            var b = new Bitmap(t, this);
            b.scale(Std.parseFloat(info[1]));
            if (info.length > 3)
            {
              b.x = Std.parseFloat(info[2]) * Const.TILE_SIZE;
              b.y = Std.parseFloat(info[3]) * Const.TILE_SIZE;
              if (info.length > 5)
              {
                b.x += Std.parseFloat(info[4]);
                b.y += Std.parseFloat(info[5]);
              }
            }
          }
        case LObjectGroup(group):
          
        default:
      }
    }
    
    final treshold = Const.MAP_SCALE;
    var j = 0;
    while (routeSegments.length > 1)
    {
      var seg = routeSegments.shift();
      var start = seg[0];
      var end = seg[seg.length - 1];
      var len;
      do {
        len = routeSegments.length;
        var i = 0;
        while (i < routeSegments.length)
        {
          var oseg = routeSegments[i++];
          var pt0 = oseg[0];
          var pt1 = oseg[oseg.length - 1];
          if (Math.abs(pt0.x - start.x) < treshold && Math.abs(pt0.y - start.y) < treshold)
          {
            oseg.reverse();
            seg.shift();
            seg = oseg.concat(seg);
            routeSegments.remove(oseg);
            start = pt1;
            break;
          }
          else if (Math.abs(pt1.x - start.x) < treshold && Math.abs(pt1.y - start.y) < treshold)
          {
            seg.shift();
            seg = oseg.concat(seg);
            routeSegments.remove(oseg);
            start = pt0;
            break;
          }
          else if (Math.abs(pt0.x - end.x) < treshold && Math.abs(pt0.y - start.y) < treshold)
          {
            seg.pop();
            seg = seg.concat(oseg);
            routeSegments.remove(oseg);
            end = pt1;
            break;
          }
          else if (Math.abs(pt1.x - end.x) < treshold && Math.abs(pt1.y - end.y) < treshold)
          {
            oseg.reverse();
            seg.pop();
            seg = seg.concat(oseg);
            routeSegments.remove(oseg);
            end = pt0;
            break;
          }
        }
      } while (routeSegments.length != len);
      if (Math.abs(start.x - end.x) < treshold && Math.abs(start.y - end.y) < treshold)
      {
        seg.pop();
      }
      route = route.concat(seg);
      j++;
    }
    if (routeSegments.length > 0)
      route = route.concat(routeSegments[0]);
    var startOX = startX * Const.TILE_SIZE + Const.TILE_SIZE / 2;
    var startOY = startY * Const.TILE_SIZE + Const.TILE_SIZE / 2;
    final startTreshold = Const.MAP_SCALE * 2;
    for (i in 0...route.length)
    {
      var pt = route[i];
      if (Math.abs(pt.x - startOX) < startTreshold && Math.abs(pt.y - startOY) < startTreshold)
      {
        if (i != 0)
        {
          var left = route.splice(0, i);
          route = route.concat(left);
        }
        break;
      }
    }
  }
  
  // override private function onAdd()
  // {
  //   super.onAdd();
  //   Physics.instance.renderCallbacks.pop();
  //   Physics.instance.renderCallbacks.push(drawSelf);
  // }
  
  function drawSelf(g:Graphics)
  {
    g.lineStyle(2, 0xff);
    for (pt in route)
      g.lineTo(pt.x, pt.y);
    g.lineTo(route[0].x, route[0].y);
    g.lineStyle();
    g.endFill();
    g.beginFill(0xff00, 0.2);
    for (pt in route)
      g.drawCircle(pt.x, pt.y, 25);
    g.endFill();
  }
  
  override private function sync(ctx:RenderContext)
  {
    super.sync(ctx);
  }
  
}