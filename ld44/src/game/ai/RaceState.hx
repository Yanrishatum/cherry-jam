package game.ai;

import hxd.Math;
import util.DebugDisplay;
import differ.math.Vector;

class RaceState {
  
  public var cars:Array<Car>;
  public var player:Car;
  public var states:Array<AIState>;
  public var route:Array<RoutePoint>;
  public var length:Float = 0;
  public var started:Bool;
  
  public function new()
  {
    cars = new Array();
    states = new Array();
  }
  
  public function addCar(car:Car)
  {
    car.race = this;
    if (car.ai != null)
    {
      car.ai.race = this;
      states.push(car.ai);
    }
    if (car.isPlayer) player = car;
    cars.push(car);
  }
  
  public function setRoute(pts:Array<Vector>, startAngle:Float)
  {
    var trackAngle = Math.abs(Math.angle(Math.atan2(pts[1].y - pts[0].y, pts[1].x - pts[0].x) - startAngle));
    if (trackAngle > 0.1) pts.reverse();
    var last:RoutePoint = null;
    route = new Array();
    for (pt in pts)
    {
      var rpt = new RoutePoint(pt, last);
      route.push(rpt);
      last = rpt;
    }
    var first = route[0];
    var xx = last.vec.x - first.vec.x;
    var yy = last.vec.y - first.vec.y;
    last.length = Math.sqrt(xx * xx + yy * yy);
    last.next = first;
    first.prev = last;
    length = last.distance + last.length;
  }
  
  public function update()
  {
    for (c in cars)
    {
      routePosition(c);
    }
    for (s in states) s.context.evaluate(s);
    // DebugDisplay.info([
    //   for (s in states) 'Engine: ${s.engine*100}\nPos: ${s.car.position}'
    // ].join("\n"), 300);
    if (player.laps >= 3)
    {
      var r = LD.roster[Std.int(LD.roster.length * Math.random())];
      Main.inst.setMap(r.map, r.layer);
      // trace("END");
    }
  }
  
  public function carPlace(car:Car)
  {
    var list = cars.copy();
    list.sort(placeSort);
    return list.indexOf(car) + 1;
  }
  
  public function carSelector(who:String, car:Car)
  {
    var closest:Float = Math.POSITIVE_INFINITY;
    var cc:Car = null;
    var list = cars.copy();
    list.sort(placeSort);
    switch(who)
    {
      case "nearest":
        var idx = list.indexOf(car);
        var dist0 = Math.abs((idx > 0 ? list[idx - 1].position : list[list.length - 1].position - length) - car.position);
        var dist1 = Math.abs((idx < list.length - 1 ? list[idx + 1].position : list[0].position + length) - car.position);
        if (dist0 < dist1)
        {
          cc = idx > 0 ? list[idx - 1] : list[list.length - 1];
          closest = dist0;
        }
        else 
        {
          cc = idx < list.length - 1 ? list[idx + 1] : list[0];
          closest = dist1;
        }
      case "first":
        cc = list[0];
        closest = Math.abs(cc.realPos() - car.realPos());
      case "second":
        cc = list[1];
        closest = Math.abs(cc.realPos() - car.realPos());
      case "third": // TODO
        cc = list[2];
        closest = Math.abs(cc.realPos() - car.realPos());
      case "last": // TODO
        cc = list[list.length - 1];
        closest = Math.abs(cc.realPos() - car.realPos());
      case "in back":
        var idx = list.indexOf(car);
        cc = idx < list.length - 1 ? list[idx+1] : list[0];
        closest = Math.abs(cc.realPos() - car.realPos());
      case "in front":
        var idx = list.indexOf(car);
        cc = idx > 0 ? list[idx - 1] : list[list.length - 1];
        closest = Math.abs(cc.realPos() - car.realPos());
    }
    return { car: cc, dist: closest };
  }
  
  public function carAtPlace(place:Int)
  {
    var list = cars.copy();
    list.sort(placeSort);
    if (place < 1) return list[0];
    if (place >= list.length) return list[list.length - 1];
    return list[place - 1];
  }
  
  function placeSort(a:Car, b:Car)
  {
    var d = a.realPos() - b.realPos();
    if (d > 0) return -1;
    else if (d < 0) return 1;
    return 0;
  }
  
  public function routePosition(car:Car)
  {
    var x = car.x;
    var y = car.y;
    var xy = new Vector(x, y);
    var dist:Float = Math.POSITIVE_INFINITY;
    var curr:RoutePoint = null;
    var next:RoutePoint = null;
    var prev:RoutePoint = null;
    var rtmax = car.node != null ? route.indexOf(car.node) + 4 : 4;
    var rtmin = rtmax - 5;
    var ptx, pty;
    while (rtmin < rtmax)
    {
      var pt = rtmin < 0 ? route[route.length + rtmin] : route[rtmin % route.length];
      rtmin++;
      ptx = pt.vec.x - x;
      pty = pt.vec.y - y;
      var d = ptx * ptx + pty * pty;
      if (d < dist)
      {
        dist = d;
        curr = pt;
      }
    }
    prev = curr.prev;
    next = curr.next;
    
    var t0 = curr.calcT(xy);
    var t1 = next.calcT(xy);
    var t2 = prev.calcT(xy);
    var prevPos = car.position;
    if (t0 > 1)
    {
      car.node = next;
      car.position = next.distance + next.length * t1;
    }
    else if (t0 < 0)
    {
      car.node = prev;
      car.position = prev.distance + prev.length * t2;
    }
    else
    {
      car.node = curr;
      car.position = curr.distance + curr.length * t0;
    }
    // if (prevPos > car.position)
    // {
    //   if (car.position < route[0].length)
    //     car.laps++;
    // }
    // else if (prevPos < route[0].length && car.position > route[route.length - 1].distance)
    //   car.laps--;
  }
  
}

class RoutePoint
{
  
  public var vec:Vector;
  public var distance:Float = 0;
  public var length:Float = 0;
  public var next:RoutePoint;
  public var prev:RoutePoint;
  
  public function new(pt:Vector, prev:RoutePoint)
  {
    this.vec = pt;
    if (prev != null)
    {
      var xx = pt.x - prev.vec.x;
      var yy = pt.y - prev.vec.y;
      prev.length = Math.sqrt(xx * xx + yy * yy);
      prev.next = this;
      this.prev = prev;
      distance = prev.distance + prev.length;
    }
    else 
    {
      distance = 0;
    }
  }
  
  public function calcT(pt:Vector)
  {
    
    var abx = next.vec.x - vec.x;
    var aby = next.vec.y - vec.y;
    
    var vx = pt.x - vec.x;
    var vy = pt.y - vec.y;
    
    return (vx * abx + vy * aby) / (abx * abx + aby * aby);
    
  }
  
}