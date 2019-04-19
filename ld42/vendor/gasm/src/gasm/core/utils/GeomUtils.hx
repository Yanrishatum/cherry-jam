package gasm.core.utils;

import gasm.core.math.geom.Point;
import gasm.core.math.geom.Rectangle;

class GeomUtils {
    inline static public function hits(rect:Rectangle, point:Point):Bool {
        return point.x > rect.x && point.x < rect.x + rect.w && point.y > rect.y && point.y < rect.y + rect.h;
    }

    inline static public function addPoints(a:Point, b:Point):Point {
        return {x:a.x + b.x, y: a.y + b.y};
    }
}
