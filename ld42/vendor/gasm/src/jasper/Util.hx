/*
 * Copyright (c) 2013-2017, Nucleic Development Team.
 * Haxe Port Copyright (c) 2017 Jeremy Meltingtallow
 *
 * Distributed under the terms of the Modified BSD License.
 *  
 * The full license is in the file COPYING.txt, distributed with this software.
*/

package jasper;

class Util 
{
    private static inline var EPS = 1.0e-8;
    public static inline var FLOAT_MAX = 1.79769313486231e+308;

    /**
     *  [Description]
     *  @param value - 
     *  @return Bool
     */
    public static function nearZero(value :Float) : Bool
    {
        return value < 0.0 ? -value < EPS : value < EPS;
    }
}