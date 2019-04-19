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

class Row 
{
    public var m_constant (default, null):Float;
    public var m_cells (default, null) = new FloatMap();

    public function new(constant :Float = 0) : Void
    {
        this.m_constant = constant;
    }

    public static inline function fromRow(other :Row) : Row
    {
        var row = new Row(other.m_constant);
        for(it in other.m_cells.keyValIterator()) {
            row.m_cells[it.first] = it.second;
        }
        return row;
    }

    /**
     * Add a constant value to the row constant.
     * The new value of the constant is returned.
     */
    public function add(value :Float) : Float
    {
        return m_constant += value;
    }

    /**
     *  Insert a symbol into the row with a given coefficient.
     *  If the symbol already exists in the row, the coefficient will be
     *  added to the existing coefficient. If the resulting coefficient
     *  is zero, the symbol will be removed from the row.
     */
    public function insertSymbol( symbol :Symbol, coefficient :Float = 1.0 ) : Void
    {
        if( Util.nearZero( m_cells[ symbol ] += coefficient ) )
            m_cells.remove( symbol );
    }

    /**
     *  Insert a row into this row with a given coefficient.
     *  The constant and the cells of the other row will be multiplied by
     *  the coefficient and added to this row. Any cell with a resulting
     *  coefficient of zero will be removed from the row.
     */
    public function insertRow( other :Row, coefficient :Float = 1.0 ) : Void
    {
        m_constant += other.m_constant * coefficient;
        for(it in other.m_cells.keyValIterator()) {
            var coeff = it.second * coefficient;
            if( Util.nearZero( m_cells[ it.first ] += coeff ) )
                m_cells.remove( it.first );
        }
    }

    /**
     *  Remove the given symbol from the row.
     */
    public function remove( symbol :Symbol ) : Void
    {
        m_cells.remove(symbol);
    }

    /**
     *  Reverse the sign of the constant and all cells in the row.
     */
    public function reverseSign() : Void
    {
        m_constant = -m_constant;
        for( it in m_cells.keyValIterator() ) {
            m_cells[it.first] = -it.second;
        }
    }

    /**
     *  Solve the row for the given symbol.
     *  This method assumes the row is of the form a * x + b * y + c = 0
     *  and (assuming solve for x) will modify the row to represent the
     *  right hand side of x = -b/a * y - c / a. The target symbol will
     *  be removed from the row, and the constant and other cells will
     *  be multiplied by the negative inverse of the target coefficient.
     *  The given symbol *must* exist in the row.
     */
    public function solveFor( symbol :Symbol ) : Void
    {
        var coeff = -1.0 / m_cells[ symbol ];
        m_cells.remove( symbol );
        m_constant *= coeff;
        for( it in m_cells.keyValIterator())
            m_cells[it.first] *= coeff;
    }

    /**
     *  Solve the row for the given symbols.
     *  This method assumes the row is of the form x = b * y + c and will
     *  solve the row such that y = x / b - c / b. The rhs symbol will be
     *  removed from the row, the lhs added, and the result divided by the
     *  negative inverse of the rhs coefficient.
     *  The lhs symbol *must not* exist in the row, and the rhs symbol
     *  *must* exist in the row.
     */
    public function solveForSymbols( lhs :Symbol, rhs :Symbol ) : Void
    {
        insertSymbol( lhs, -1.0 );
        solveFor( rhs );
    }

    /**
     *  Get the coefficient for the given symbol.
     *  If the symbol does not exist in the row, zero will be returned.
     */
    public function coefficientFor( symbol :Symbol ) : Float
    {
        return m_cells[symbol];
    }

    /**
     *  Substitute a symbol with the data from another row.
     *  Given a row of the form a * x + b and a substitution of the
     *  form x = 3 * y + c the row will be updated to reflect the
     *  expression 3 * a * y + a * c + b.
     *  If the symbol does not exist in the row, this is a no-op.
     */
    public function substitute( symbol :Symbol, row :Row ) : Void
    {
        if( m_cells.exists( symbol ) )
        {
            var coefficient = m_cells.get( symbol );
            m_cells.remove( symbol );
            insertRow( row, coefficient );
        }
    }
}