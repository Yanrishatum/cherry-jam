import hxd.Res;

using StringTools;

typedef L = LocaleImpl;

class LocaleImpl {
  
  static var header:Array<String>;
  static var map:Map<String, Array<String>>;
  static var current:Int;
  
  static var callbacks:Array<Void->Void>;
  static var textHook:TextHook;
  
  @:noCompletion
  public static function init() {
    map = [];
    textHook = new TextHook();
    callbacks = [textHook.refresh];
    
    
    final data = Res.locales.entry.getBytes();
    final len = data.length;
    var pos = 0;
    
    function readEntry(start, end) {
      var str = data.getString(start, end - start);
      if (str.charCodeAt(0) == '"'.code)
        return str.substr(1, str.length - 2).replace('""', '"');
      return str;
    }
    
    function readLine():Array<String> {
      var arr = [];
      var start = pos;
      while (pos < len) {
        switch (data.get(pos)) {
          case ','.code:
            // Entry separator
            arr.push(readEntry(start, pos));
            start = ++pos;
          case '"'.code:
            // Validation:
            // if (pos != start) throw "Invalid quotation"
            
            // Quoted entry - specially process ""
            pos++;
            while (pos < len) {
              if (data.get(pos++) == '"'.code) {
                // Something else, most likely ',', CR/LF or end of stream
                if (pos == len || data.get(pos) != '"'.code) break;
                else pos++;
              }
            }
          case '\r'.code:
            // Part of \r\n
            arr.push(readEntry(start, pos));
            pos += 2;
            return arr;
          case '\n'.code:
            arr.push(readEntry(start, pos));
            pos++;
            return arr;
          default:
            pos++;
        }
      }
      // End of stream
      arr.push(readEntry(start, pos));
      return arr;
    }
    
    header = readLine();
    header.shift(); // key
    
    while (pos < len) {
      var line = readLine();
      var key = line.shift();
      map.set(key, line);
    }
  }
  
  @:noCompletion
  public static function getLocaleList() {
    var res = [];
    for (h in header) {
      if (h == "comment") continue;
      res.push(h);
    }
    return res;
  }
  
  @:noCompletion
  public static function change(lang:String):Bool {
    var idx = header.indexOf(lang);
    if (idx == -1) return false;
    changeRaw(idx);
    return true;
  }
  
  @:noCompletion
  public static inline function changeRaw(idx:Int) {
    current = idx;
    for (cb in callbacks) cb();
  }
  
  @:noCompletion
  public static inline function listen(cb:Void->Void) {
    callbacks.push(cb);
  }
  
  @:noCompletion
  public static inline function unlisten(cb:Void->Void) {
    callbacks.remove(cb);
  }
  
  public static inline function l(id:String):String {
    return get(id, current);
  }
  
  public static inline function hasLocaleKey(id:String) {
    return map.exists(id);
  }
  
  static function get(id:String, index:Int):String {
    var idx = map.get(id);
    if (idx == null || idx[index] == null || idx[index] == "") {
      #if (debug && verbose_locale)
      return "#MISSING(" + header[index] + "@" + id + ")";
      #elseif (fancy_missing)
      if (index != 0) return get(id, 0);
      return id.charAt(0).toUpperCase() + id.substr(1).replace("_", " ");
      #else
      return id;
      #end
    }
    return idx[index];
  }
  
  public static function listenText(text:h2d.Text, id:String):Void {
    textHook.add(text, id);
  }
  
  public static function unlistenText(text:h2d.Text):Void {
    textHook.remove(text);
  }
  
  public static function unlistenAuto() {
    textHook.cleanup();
  }
  
  #if (sys && debug)
  
  public static function refresh() {
    
  }
  
  #end
  
}

private class TextHook {
  
  var list:Map<String, Array<h2d.Text>>;
  
  public function new() {
    list = [];
  }
  
  public function add(text:h2d.Text, id:String) {
    var l = list.get(id);
    if (l == null) {
      l = [text];
      list.set(id, l);
    } else {
      l.push(text);
    }
    text.text = id.l();
  }
  
  public function remove(text:h2d.Text) {
    for (list in list) {
      list.remove(text);
    }
  }
  
  public function cleanup() {
    for (list in list) {
      var i = 0;
      while (i < list.length) {
        var txt = list[i];
        if (txt.getScene() == null) list.remove(txt);
        else i++;
      }
    }
  }
  
  public function refresh() {
    for (kv in list.keyValueIterator()) {
      var n = kv.key.l();
      for (t in kv.value) t.text = n;
    }
  }
  
}