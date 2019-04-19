/*
 * Copyright (c) 2013-2017, Nucleic Development Team.
 * Haxe Port Copyright (c) 2017 Jeremy Meltingtallow
 *
 * Distributed under the terms of the Modified BSD License.
 *  
 * The full license is in the file COPYING.txt, distributed with this software.
*/

package jasper;

@:notNull
abstract Strength(Float) to Float from Float
{
    public inline function new(str :Float) : Void
    {
        this = str;
    }

    @:op(A < B) static function lt(a :Strength, b :Strength) : Bool;
    @:op(A > B) static function gt(a :Strength, b :Strength) : Bool;
    @:op(-A) function negate() : Strength;

    public static inline var REQUIRED :Strength = 1001001000;
    public static inline var STRONG :Strength = 1000000;
    public static inline var MEDIUM :Strength = 1000;
    public static inline var WEAK :Strength = 1;

    public static function create(a :Float, b :Float, c :Float, w :Float = 1.0) : Strength
    {
        var result = 0.0;
        result += Math.max( 0.0, Math.min( 1000.0, a * w ) ) * 1000000.0;
        result += Math.max( 0.0, Math.min( 1000.0, b * w ) ) * 1000.0;
        result += Math.max( 0.0, Math.min( 1000.0, c * w ) );
        return new Strength(result);
    }

    public static function clip(value :Strength) :Strength
    {
        return new Strength(Math.max( 0.0, Math.min( REQUIRED, value ) ));
    }
}
