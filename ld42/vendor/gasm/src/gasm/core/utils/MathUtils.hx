package gasm.core.utils;

class MathUtils {
    /**
     * Returns a string representation of the number in fixed-point notation.
     * Fixed-point notation means that the string will contain a specific number of digits
     * after the decimal point, as specified in the fractionDigits parameter.
     * The valid range for the fractionDigits parameter is from 0 to 20.
     * Specifying a value outside this range throws an exception.
     * @param fractionDigits An integer between 0 and 20, inclusive, that represents the desired number of decimal places.
     * @throws Throws an exception if the fractionDigits argument is outside the range 0 to 20.
     */
    public static inline function toFixed(v:Float, fractionDigits:Int):String {
        #if (js || flash)
            return untyped v.toFixed(fractionDigits);
        #else
        if(fractionDigits < 0 || fractionDigits > 20) throw 'toFixed have a range of 0 to 20. Specified value is not within expected range.';
        var b = Math.pow(10, fractionDigits);
        var s = Std.string(v);
        var dotIndex = s.indexOf('.');
        if(dotIndex >= 0) {
            var diff = fractionDigits - (s.length - (dotIndex + 1));
            if(diff > 0) {
                s = StringTools.rpad(s, "0", s.length + diff);
            } else {
                s = Std.string(Math.round(v * b) / b);
            }
        } else {
            s += ".";
            s = StringTools.rpad(s, "0", s.length + fractionDigits);
        }
        return s;
        #end
    }

    /**
    * Returns radians from degree
    **/
    public static inline function degToRad(deg:Float):Float {
        return (Math.PI / 180) * deg;
    }
}
