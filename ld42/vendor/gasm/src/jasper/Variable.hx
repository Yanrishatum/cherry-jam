/*
 * Copyright (c) 2013-2017, Nucleic Development Team.
 * Haxe Port Copyright (c) 2017 Jeremy Meltingtallow
 *
 * Distributed under the terms of the Modified BSD License.
 *  
 * The full license is in the file COPYING.txt, distributed with this software.
*/

package jasper;

class _Variable_
{
    public var m_name (default, null):String;
    public var m_value :Float;

    /**
     *  [Description]
     *  @param name - 
     */
    @:allow(jasper.Variable)
    private function new(name :String) : Void
    {
        this.m_name = name;
        this.m_value = 0.0;
    }

    /**
     *  [Description]
     *  @return String
     */
    public function toString() : String
    {
        return "name: " + m_name + " value: " + m_value;
    }
}

//*********************************************************************************************************

@:forward
@:notNull
abstract Variable(_Variable_) to _Variable_
{
    public inline function new(name :String = "") : Void
    {
        this = new _Variable_(name);
    }

    @:op(A*B) @:commutative static function multiplyValue(variable :Variable, coefficient :Value) : Term
    {
        return new Term( variable, coefficient );
    }

    @:op(A/B) static function divideValue(variable :Variable, denominator :Value) : Term
    {
        return variable * ( 1.0 / denominator );
    }

    @:op(-A) static function negateVariable(variable :Variable) : Term
    {
        return variable * -1.0;
    }

    @:op(A+B) static function addVariable(first :Variable, second :Variable) : Expression
    {
        return new Term(first) + second;
    }

    @:op(A+B) @:commutative static function addValue(variable :Variable, constant :Value) : Expression
    {
        return new Term(variable) + constant;
    }

    @:op(A-B) static function subtractExpression(variable :Variable, expression :Expression) : Expression
    {
        return variable + -expression;
    }

    @:op(A-B) static function subtractTerm(variable :Variable, term :Term) : Expression
    {
        return variable + -term;
    }

    @:op(A-B) static function subtractVariable(first :Variable, second :Variable) : Expression
    {
        return first + -second;
    }

    @:op(A-B) static function subtractValue(variable :Variable, constant :Value) : Expression
    {
        return variable + -constant;
    }

    @:op(A==B) static function equalsVariable(first :Variable, second :Variable) : Constraint
    {
        return new Term(first) == second;
    }

    @:op(A==B) @:commutative static function equalsValue(variable :Variable, constant :Value) : Constraint
    {
        return new Term(variable) == constant;
    }

    @:op(A<=B) static function lteExpression(variable :Variable, expression :Expression) : Constraint
    {
        return expression >= variable;
    }

    @:op(A<=B) static function lteTerm(variable :Variable, term :Term) : Constraint
    {
        return term >= variable;
    }

    @:op(A<=B) static function lteVariable(first :Variable, second :Variable) : Constraint
    {
        return new Term(first) <= second;
    }

    @:op(A<=B) static function lteValue(variable :Variable, constant :Value) : Constraint
    {
        return new Term(variable) <= constant;
    }

    @:op(A>=B) static function gteExpression(variable :Variable, expression :Expression) : Constraint
    {
        return expression <= variable;
    }

    @:op(A>=B) static function gteTerm(variable :Variable, term :Term) : Constraint
    {
        return term <= variable;
    }

    @:op(A>=B) static function gteVariable(first :Variable, second :Variable) : Constraint
    {
        return new Term(first) >= second;
    }

    @:op(A>=B) static function gteValue(variable :Variable, constant :Value) : Constraint
    {
        return new Term(variable) >= constant;
    }
}