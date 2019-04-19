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
abstract Value(Float) to Float from Float
{
    @:op(A*B) static function multiply(a:Value,B:Value):Value;
    @:op(A/B) static function divide(a:Value,B:Value):Value;
    @:op(A+B) static function add(a:Value,B:Value):Value;
    @:op(-A) static function negate(a:Value):Value;

    @:op(A-B) static function subtractExpression(constant :Value, expression :Expression) : Expression
    {
        return -expression + constant;
    }

    @:op(A-B) static function subtractTerm(constant :Value, term :Term) : Expression
    {
        return -term + constant;
    }

    @:op(A-B) static function subtractVariable(constant :Value, variable :Variable) : Expression
    {
        return -variable + constant;
    }

    @:op(A<=B) static function lteExpression(constant :Value, expression :Expression) : Constraint
    {
        return expression >= constant;
    }

    @:op(A<=B) static function lteTerm(constant :Value, term :Term) : Constraint
    {
        return term >= constant;
    }

    @:op(A<=B) static function lteVariable(constant :Value, variable :Variable) : Constraint
    {
        return variable >= constant;
    }

    @:op(A>=B) static function gteExpression(constant :Value, expression :Expression) : Constraint
    {
        return expression <= constant;
    }

    @:op(A>=B) static function gteTerm(constant :Value, term :Term) : Constraint
    {
        return term <= constant;
    }

    @:op(A>=B) static function gteVariable(constant :Value, variable :Variable) : Constraint
    {
        return variable <= constant;
    }
}