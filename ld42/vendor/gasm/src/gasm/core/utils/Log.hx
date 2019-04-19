package gasm.core.utils;
class Log {
    static public function log(?text:String, ?fields:Array<Dynamic>) {
        trace("LOG:", text);
    }
    static public function info(?text:String, ?fields:Array<Dynamic>) {
        trace("INFO:", text);
    }
    static public function warn(?text:String, ?fields:Array<Dynamic>) {
        trace("WARN:", text);
    }
    static public function error(?text:String, ?fields:Array<Dynamic>) {
        trace("ERROR:", text);
    }
}
