/*
 * Copyright (c) 2013-2017, Nucleic Development Team.
 * Haxe Port Copyright (c) 2017 Jeremy Meltingtallow
 *
 * Distributed under the terms of the Modified BSD License.
 *  
 * The full license is in the file COPYING.txt, distributed with this software.
*/

package jasper;

class _Term_
{
    public var m_variable (default, null):Variable;
    public var m_coefficient (default, null):Float;

    /**
     *  [Description]
     *  @param variable - 
     *  @param coefficient - 
     */
    @:allow(jasper.Term)
    private function new(variable :Variable, coefficient :Float) : Void
    {
        this.m_variable = variable;
        this.m_coefficient = coefficient;
    }

    /**
     *  [Description]
     *  @return Float
     */
    public function value() : Float
    {
        return m_coefficient * m_variable.m_value;
    }

    /**
     *  [Description]
     *  @return String
     */
    public function toString() : String
    {
        return "variable: (" + m_variable + ") coefficient: "  + m_coefficient;
    }
}

//*********************************************************************************************************

@:forward
@:forwardStatics
@:notNull
abstract Term(_Term_)
{
    public inline function new(variable :Variable, coefficient :Float = 1.0) : Void
    {
        this = new _Term_(variable, coefficient);
    }

    @:op(A*B) @:commutative static function multiplyValue(term :Term, coefficient :Value) : Term
    {
        return new Term( term.m_variable, term.m_coefficient * coefficient );
    }

    @:op(A/B) static function divideValue(term :Term, denominator :Value) : Term
    {
        return term * ( 1.0 / denominator );
    }

    @:op(-A) static function negateTerm(term :Term) : Term
    {
        return term * -1.0;
    }

    @:op(A+B) static function addTerm(first :Term, second :Term) : Expression
    {
        var terms = new Array<Term>();
        terms.push(first);
        terms.push(second);

        return new Expression(terms);
    }

    @:op(A+B) @:commutative static function addVariable(term :Term, variable :Variable) : Expression
    {
        return term + new Term(variable);
    }

    @:op(A+B) @:commutative static function addValue(term :Term, constant :Value) : Expression
    {
        return new Expression([term], constant);
    }

    @:op(A-B) static function subtractExpression(term :Term, expression :Expression) : Expression
    {
        return -expression + term;
    }

    @:op(A-B) static function subtractTerm(first :Term, second :Term) : Expression
    {
        return first + -second;
    }

    @:op(A-B) static function subtractVariable(term :Term, variable :Variable) : Expression
    {
        return term + -variable;
    }

    @:op(A-B) static function subtractValue(term :Term, constant :Value) : Expression
    {
        return term + -constant;
    }

    @:op(A==B) static function equalsTerm(first :Term, second :Term) : Constraint
    {
        return new Expression([first]) == second;
    }

    @:op(A==B) @:commutative static function equalsVariable(term :Term, variable :Variable) : Constraint
    {
        return new Expression([term]) == variable;
    }

    @:op(A==B) @:commutative static function equalsValue(term :Term, constant :Value) : Constraint
    {
        return new Expression([term]) == constant;
    }

    @:op(A<=B) static function lteExpression(term :Term, expression :Expression) : Constraint
    {
        return expression >= term;
    }

    @:op(A<=B) static function lteTerm(first :Term, second :Term) : Constraint
    {
        return new Expression([first]) <= second;
    }

    @:op(A<=B) static function lteVariable(term :Term, variable :Variable) : Constraint
    {
        return new Expression([term]) <= variable;
    }

    @:op(A<=B) static function lteValue(term :Term, constant :Value) : Constraint
    {
        return new Expression([term]) <= constant;
    }

    @:op(A>=B) static function gteExpression(term :Term, expression :Expression) : Constraint
    {
        return expression <= term;
    }

    @:op(A>=B) static function gteTerm(first :Term, second :Term) : Constraint
    {
        return new Expression([first]) >= second;
    }

    @:op(A>=B) static function gteVariable(term :Term, variable :Variable) : Constraint
    {
        return new Expression([term]) >= variable;
    }

    @:op(A>=B) static function gteValue(term :Term, constant :Value) : Constraint
    {
        return new Expression([term]) >= constant;
    }
}