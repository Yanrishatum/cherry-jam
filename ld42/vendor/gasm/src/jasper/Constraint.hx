/*
 * Copyright (c) 2013-2017, Nucleic Development Team.
 * Haxe Port Copyright (c) 2017 Jeremy Meltingtallow
 *
 * Distributed under the terms of the Modified BSD License.
 *  
 * The full license is in the file COPYING.txt, distributed with this software.
*/

package jasper;

import jasper.ds.FloatMap;

class _Constraint_ 
{
    public var m_expression (default, null):Expression;
    public var m_strength (default, null):Strength;
    public var m_op (default, null):RelationalOperator;

    /**
     *  [Description]
     *  @param expr - 
     *  @param op - 
     *  @param strength - 
     */
    private function new(expr :Expression, op :RelationalOperator, strength :Strength) : Void
    {
        this.m_expression = expr;
        this.m_op = op;
        this.m_strength = strength;
    }

    /**
     *  [Description]
     *  @param other - 
     *  @param strength - 
     *  @return Constraint
     */
    public static function fromConstraint(other :Constraint, strength :Strength) : Constraint
    {
        strength = Strength.clip(strength);
        return new _Constraint_(other.m_expression,other.m_op,strength);
    }

    /**
     *  [Description]
     *  @param expr - 
     *  @param op - 
     *  @param strength - 
     */
    public static function fromExpression(expr :Expression, op :RelationalOperator, strength :Strength) : Constraint
    {
        expr = reduce(expr);
        strength = Strength.clip(strength);
        return new _Constraint_(expr,op,strength);
    }

    /**
     *  [Description]
     *  @param expr - 
     *  @return Expression
     */
    private static function reduce(expr :Expression) :Expression
    {
        var vars = new FloatMap();

        for(term in expr.m_terms) {
            vars[term.m_variable] += term.m_coefficient;
        }

        var terms = [for (key in vars.keys()) new Term(key, vars.get(key))];

        return new Expression(terms, expr.m_constant);
    }

    /**
     *  [Description]
     *  @return String
     */
    public function toString() : String
    {
        return "expression: (" + m_expression + ") strength: " + m_strength + " operator: " + m_op;
    }
}

enum RelationalOperator
{
    OP_LE;
    OP_GE;
    OP_EQ;
}

@:forward
@:forwardStatics
@:notNull
abstract Constraint(_Constraint_) to _Constraint_ from _Constraint_
{
    public function new(expr :Expression, op :RelationalOperator, strength :Strength = Strength.REQUIRED) : Void
    {
        this = _Constraint_.fromExpression(expr, op, strength);
    }

    @:op(A|B) @:commutative static function modifyStrength(constraint :Constraint, strength :Strength) : Constraint
    {
        return _Constraint_.fromConstraint(constraint, strength);
    }
}