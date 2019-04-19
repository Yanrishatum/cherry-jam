package gasm.core.utils.texture;

class TexturePackerImport {
    public static function parse(spriteJson:TextureData, behaviorJson:String = null, name:String = ""):ParseResult {
        // var bjson:Dynamic = Json.parse(behaviorJson);

        var frames:Array<SpritesheetFrame> = [];
        //var behaviors = new StringMap<Behavior>();
        // var behaviorFrames:Array<Int> = [];

        if (name == "") {
            name = spriteJson.meta.image;
        }

        var fields = Reflect.fields(spriteJson.frames);
        for (frame in fields) {
            var f = Reflect.field(spriteJson.frames, frame);
            var frameData:TextureFrame = f;
            frames.push({
                x:frameData.frame.x,
                y:frameData.frame.y,
                width:frameData.frame.w,
                height:frameData.frame.h,
                offsetX:frameData.spriteSourceSize.x,
                offsetY:frameData.spriteSourceSize.y
            });

        }
/*
        var bfields = Reflect.fields(bjson);
        var count:Int = 0;
        for (prop in bfields) {
            var frame = Reflect.field(bjson, prop);
            var framelist:Array<Int>;
            framelist = frame.frames;

            var finalframelist:Array<Int> = new Array<Int>();
            for (f in framelist) {
                finalframelist.push(f - 1);
            }

            var behaviorData:BehaviorData = new BehaviorData(prop, finalframelist, frame.loop, frame.speed, 0, 0);
            behaviors.set(prop, behaviorData);

        }
*/
        return {frames:frames};
    }
}