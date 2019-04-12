package gasm.heaps;

import gasm.heaps.components.HeapsSpriteComponent;
import gasm.heaps.systems.HeapsCoreSystem;
import gasm.core.IEngine;
import gasm.core.components.AppModelComponent;
import gasm.core.Context;
import gasm.core.Engine;
import gasm.core.Entity;
import gasm.core.ISystem;
import gasm.heaps.systems.HeapsRenderingSystem;
import gasm.heaps.systems.HeapsSoundSystem;
import gasm.assets.Loader;
import hxd.App;
/**
 * ...
 * @author Leo Bergman
 */
class HeapsContext extends App implements Context {
    public var baseEntity(get, null):Entity;
    public var systems(default, null):Array<ISystem>;
    public var appModel(default, null):AppModelComponent;


    var _engine:IEngine;
    var _core:ISystem;
    var _renderer:ISystem;
    var _sound:ISystem;
	var _assetContainers:AssetContainers;
    var _assetConfig:AssetConfig;
	

    public function new(?core:ISystem, ?renderer:ISystem, ?sound:ISystem, ?engine:IEngine) {
        _core = core;
        _renderer = renderer;
        _sound = sound;
        _engine = engine;
        super();

        appModel = new AppModelComponent();
    } 
    public function preload(progress:Int -> Void, done:Void -> Void) {
		engine.render(this);
        var bitmapFonts = new haxe.ds.StringMap<haxe.io.Bytes>();
		var loader = new Loader('assets/desc.json', _assetConfig);
		loader.onReady = function () {
			for (img in Type.getClassFields(_assetContainers.images)) {
				loader.queueItem(img, AssetType.Image);
			}
			for (snd in Type.getClassFields(_assetContainers.sounds)) {
				loader.queueItem(snd, AssetType.Sound);
			}
			for (fnt in Type.getClassFields(_assetContainers.fonts)) {
				loader.queueItem(fnt, AssetType.Font);
			}
			for (bmFnt in Type.getClassFields(_assetContainers.bitmapFonts)) {
				loader.queueItem(bmFnt, AssetType.BitmapFont);
			}
			loader.load();
		}
		loader.onComplete = function () {
			done();
		}
		loader.onProgress = function(percent:Int) {
			progress(percent);
			engine.render(this);
		}
		loader.onError = function(error:String) {
			throw error;
		}
		loader.addHandler(AssetType.Image, function(item:HandlerItem) {
			Reflect.setField(_assetContainers.images, item.id, hxd.res.Any.fromBytes('image/${item.id}', item.data).toTile());
		});

		loader.addHandler(AssetType.Sound, function(item:HandlerItem) {
			Reflect.setField(_assetContainers.sounds, item.id, hxd.res.Any.fromBytes('sound/${item.id}', item.data).toSound());
		});

		loader.addHandler(AssetType.Font, function(item:HandlerItem) {
			Reflect.setField(_assetContainers.fonts, item.id, hxd.res.Any.fromBytes('font/${item.id}', item.data).to(hxd.res.Font));//.toFont());
		});
		
		loader.addHandler(AssetType.BitmapFont, function(item:HandlerItem) {
			if(bitmapFonts.exists(item.id)) {
                var bmImg = bitmapFonts.get(item.id);
				var font = parseFont(item.id, item.data, bmImg);
				Reflect.setField(_assetContainers.fonts, item.id, font);
			} else {
				bitmapFonts.set(item.id, item.data);
			}
		});
		
		loader.addHandler(AssetType.BitmapFontImage, function(item:HandlerItem) {
			if(bitmapFonts.exists(item.id)) {
				var bmFont = bitmapFonts.get(item.id);
				var font = parseFont(item.id, bmFont, item.data);
				Reflect.setField(_assetContainers.fonts, item.id, font);
			} else {
				bitmapFonts.set(item.id, item.data);
			}
		});
    }

    override function init() {
        _core = _core != null ? _core : new HeapsCoreSystem(s2d);
        _renderer = _renderer != null ? _renderer : new HeapsRenderingSystem(s2d);
        _sound = _sound != null ? _sound : new HeapsSoundSystem();
        systems = [_core, _renderer, _sound];
        _engine = _engine != null ? _engine : new Engine(systems);

        var comp = new HeapsSpriteComponent(cast s2d);
        baseEntity.add(comp);
        baseEntity.add(appModel);
        onResize();
    }

    override function onResize() {
        var stage = hxd.Window.getInstance();
        appModel.stageSize.x = stage.width;
        appModel.stageSize.y = stage.height;
        appModel.resizeSignal.emit({width:appModel.stageSize.x, height:appModel.stageSize.y});
    }

    override function update(dt:Float) {
        _engine.tick();
    }

	@:access(h2d.Font)
	function parseFont(id:String, definition:haxe.io.Bytes, image:haxe.io.Bytes):h2d.Font {
		// Taken from https://github.com/HeapsIO/heaps/blob/master/hxd/res/BitmapFont.hx since there seems to be no way to parse bitmap font without using heaps resrouce system directly.
		var xml = new haxe.xml.Access(Xml.parse(definition.toString()).firstElement());
		var tile = hxd.res.Any.fromBytes('font/$id', image).toTile();
		var glyphs = new Map();
		var	size = Std.parseInt(xml.att.size);
		var lineHeight = Std.parseInt(xml.att.height);
		var name = xml.att.family;
		for( c in xml.elements ) {
			var r = c.att.rect.split(" ");
			var o = c.att.offset.split(" ");
			var t = tile.sub(Std.parseInt(r[0]), Std.parseInt(r[1]), Std.parseInt(r[2]), Std.parseInt(r[3]), Std.parseInt(o[0]), Std.parseInt(o[1]));
			var fc = new h2d.Font.FontChar(t, Std.parseInt(c.att.width) - 1);
			for( k in c.elements )
				fc.addKerning(k.att.id.charCodeAt(0), Std.parseInt(k.att.advance));
			var code = c.att.code;
			if( StringTools.startsWith(code, "&#") )
				glyphs.set(Std.parseInt(code.substr(2,code.length-3)), fc);
			else
				glyphs.set(c.att.code.charCodeAt(0), fc);
		}
		if( glyphs.get(" ".code) == null )
			glyphs.set(" ".code, new h2d.Font.FontChar(tile.sub(0, 0, 0, 0), size>>1));

		var font = new h2d.Font(name, size);
		font.glyphs = glyphs;
		font.lineHeight = lineHeight;
		font.tile = tile;

		var padding = 0;
		var space = glyphs.get(" ".code);
		if( space != null )
			padding = (space.t.iheight >> 1);

		var a = glyphs.get("A".code);
		if( a == null )
			a = glyphs.get("a".code);
		if( a == null )
			a = glyphs.get("0".code); // numerical only
		if( a == null )
			font.baseLine = font.lineHeight - 2 - padding;
		else
			font.baseLine = a.t.dy + a.t.height - padding;

		return font;
	}
    public function get_baseEntity():Entity {
        return _engine.baseEntity;
    }

}

typedef AssetContainers = {
	?images:Dynamic,
	?sounds:Dynamic,
	?fonts:Dynamic,
	?bitmapFonts:Dynamic,
	?atlases:Dynamic,
}