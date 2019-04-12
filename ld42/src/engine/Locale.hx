package engine;

import hxd.UString;
import hxd.Res;

typedef Locale = LocaleImpl;

class LocaleImpl
{
  
  public static var langId:Int = 0;
  
  private static var general:Tsv;
  
  public static function init(lang:String):Void
  {
    general = Tsv.parse(Res.loc.general.entry.getText());
    switch(lang)
    {
      case "ru":
        langId = 1;
      case "en":
        langId = 0;
      default:
        throw "Wtf is that lang?";
      // case "ru": f = Res.loc.ru.entry.getText();
      // case "en": f = Res.loc.en.entry.getText();
    }
  }
  
  public static function get(id:String):String
  {
    var lid = id.toLowerCase();
    var l:Array<Array<String>> = general.list;
    for (i in 0...l.length)
    {
      if (l[i][0] == lid)
      {
        return l[i][langId + 1];
      }
    }
    return "#"+id;
  }
  
}

class Tsv
{
  
  public static function parse(t:String):Tsv
  {
    return new Tsv(t);
  }
  
  public var list:Array<Array<String>>;
  
  private function new(s:UString)
  {
    list = s.split("\n").map((row:String) -> row.split("\t"));
  }
  
  public function get(index:Int, part:Int, offsetByLang:Bool = false):String
  {
    return list[index][part + (offsetByLang ? LocaleImpl.langId : 0) ];
  }
  
}