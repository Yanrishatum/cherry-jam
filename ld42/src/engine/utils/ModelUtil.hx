package engine.utils;

import haxe.ds.Vector;
import h3d.anim.LinearAnimation;
import h3d.anim.Animation;
import hxd.fmt.hmd.Library;
import hxd.res.Model;

class ModelUtil
{
  
  public static function spliceAnimations(res:Model, anims:Array<AnimSplice>)
  {
    var lib:Library = HXP.modelCache.loadLibrary(res);
    
    var source = lib.header.animations[0];
    
    for (splice in anims)
    {
      if (@:privateAccess lib.cachedAnimations.exists(splice.name)) continue;
      var len:Int = splice.end - splice.start + 1;
      var base:LinearAnimation = cast @:privateAccess lib.makeAnimation(source);
      for (obj in @:privateAccess base.getFrames())
      {
        if (obj.frames != null && obj.frames.length > 1)
        {
          var old = obj.frames;
          obj.frames = new Vector(len);
          for (i in 0...len) obj.frames[i] = old[i+splice.start];
        }
        if (obj.alphas != null && obj.alphas.length > 1)
        {
          var old = obj.alphas;
          obj.alphas = new Vector(len);
          for (i in 0...len) obj.alphas[i] = old[i+splice.start];
        }
        if (obj.uvs != null && obj.uvs.length > 1)
        {
          var old = obj.uvs;
          obj.uvs = new Vector(len);
          for (i in 0...len) obj.uvs[i] = old[i+splice.start];
        }
        if (obj.propValues != null && obj.propValues.length > 1)
        {
          var old = obj.propValues;
          obj.propValues = new Vector(len);
          for (i in 0...len) obj.propValues[i] = old[i+splice.start];
        }
      }
      @:privateAccess base.frameCount = len;
      @:privateAccess lib.cachedAnimations.set(splice.name, base);
    }
    
		// var path = anim.entry.path;
		// if( name != null ) path += ":" + name;
		// var a = anims.get(path);
  }
  
}

typedef AnimSplice =
{
  var name:String;
  var start:Int;
  var end:Int;
}