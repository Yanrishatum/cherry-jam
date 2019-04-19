package gasm.core.utils;

using gasm.core.utils.StringUtils;

class Assert {
#if (debug)
    /**
     * Asserts that a condition is true.
     * @param message If this assertion fails, the message to include in the thrown error.
     * @param fields Optional fields to be formatted with the message, see Strings.withFields.
     */
    public static function that (condition :Bool, ?message :String, ?fields :Array<Dynamic>)
    {
        if (!condition) {
            fail(message, fields);
        }
    }

    /**
     * Immediately fails an assertion. Same as Assert.that(false).
     * @param message The message to include in the thrown error.
     * @param fields Optional fields to be formatted with the message, see Strings.withFields.
     */
    public static function fail (?message :String, ?fields :Array<Dynamic>)
    {
        var error = "Assertion failed!";
        if (message != null) {
            error += " " + message;
        }
        if (fields != null) {
            error = error.withFields(fields);
        }
        throw error;
    }

#else
    // In release builds, assertions are stripped out
    inline public static function that(condition:Bool, ?message:String, ?fields:Array<Dynamic>) {}

    inline public static function fail(?message:String, ?fields:Array<Dynamic>) {}
#end
}