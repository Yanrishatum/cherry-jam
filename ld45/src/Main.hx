import haxe.Json;
import h3d.scene.Renderer;
import yatl.TweenRuntime;
import h3d.Engine;
import hxd.res.ManifestLoader;
import hxd.Event;
import h3d.scene.CameraController;
import hxd.Key;
import h3d.mat.Material;
import h3d.impl.RendererFX;
import h3d.Vector;
import h3d.scene.fwd.DirLight;
import h3d.scene.pbr.Environment;
import hxd.Pixels;
import h3d.mat.Texture;
import h3d.Matrix;
import h3d.mat.PbrMaterialSetup;
import h3d.mat.MaterialSetup;
import h3d.prim.ModelCache;
import hxd.Res;
import hxd.App;
import ld45.*;
import Util;

class Main extends App {
	
	public static var toAdd:Array<UpdateObject> = [];
	public static var toRemove:Array<UpdateObject> = [];
	static var toUpdate:Array<UpdateObject> = [];
	
	public static var instance:Main;
	
	public static var cache:ModelCache;
	
	static function main() {
		new Main();
	}
	
	public function new()
	{
		Engine.ANTIALIASING = 1;
		MaterialSetup.current = new CustomMaterialSetup();
		instance = this;
		// h3d.mat.MaterialSetup.current = new h3d.mat.PbrMaterialSetup();
		super();
	}
	
	override function init()
	{
		super.init();
		#if js
		var loader:ManifestLoader = hxd.fs.ManifestBuilder.initManifest();
		ManifestLoader.concurrentFiles = 8;
		var p = new h2d.ui.ManifestProgress(loader, _init, s2d);
		p.start();
		#else
		var dir =
		if (sys.FileSystem.exists("res"))
		{
			hxd.Res.loader = new hxd.res.Loader(new hxd.fs.LocalFileSystem("res",null));
		}
		else Res.initLocal();
		_init();
		#end
	}
	
	function _init()
	{
		TweenRuntime.ENABLE = true;
		cache = new ModelCache();
		s3d.lightSystem.ambientLight.setColor(0xffffffff);
		engine.backgroundColor = 0x443322;
		
		State.config = Json.parse(Res.balance.entry.getText());
		#if hl
		Res.balance.watch(function() { 
			State.config = Json.parse(Res.balance.entry.getText());
		});
		#end
		
		var ui = new UI(s2d);
		State.ui = ui;
		
		@:privateAccess if (!s3d.allocated) s3d.onAdd();
		var map = new GameMap(s3d);
		map.load(State.config.pool.first, 0, 0, true);
		syncUpdate();
		State.start();
		// map.fill(0,6,3,6, Rock);
		s3d.camera.pos.set(0, 45, 60);
		s3d.camera.target.set(0, 0, 0);
		// new h3d.scene.CameraController(6,s3d).initFromScene();
		new CamControl(s3d);
		//  (handleCamera);
	}
	
	public static function syncUpdate()
	{
		while (toAdd.length != 0) toUpdate.push(toAdd.shift());
		while (toRemove.length != 0) toUpdate.remove(toRemove.pop());
	}
	
	override function update(dt:Float)
	{
		inline syncUpdate();
		for (o in toUpdate) o.update();
		TweenRuntime.update(hxd.Timer.dt);
	}
	
}

class CustomMaterialSetup extends MaterialSetup
{
	
	var fogShader:FogShader;
	public function new()
	{
		super("Foggy");
		fogShader = new FogShader();
		fogShader.setPriority(-1);
		fogShader.fogColor.setColor(0xff888888);
	}
	
	override public function createMaterial():Material
	{
		var mat = super.createMaterial();
    mat.shadows = false;
    mat.staticShadows = false;
    mat.mainPass.enableLights = false;
    // mat.mainPass.addShader(fogShader);
		return mat;
	}
	
	override public function createRenderer():Renderer
	{
		return new CustomRenderer();// super.createRenderer();
	}
	
}

class CustomRenderer extends h3d.scene.fwd.Renderer
{
	
	public var outline : h3d.pass.Base = new h3d.pass.Default("outline");
	
	public function new(){
		super();
		allPasses = [defaultPass, depth, normal, shadow, outline];
	}
	
	override function render()
	{
		if( has("shadow") )
			renderPass(shadow,get("shadow"));

		if( has("depth") )
			renderPass(depth,get("depth"));

		if( has("normal") )
			renderPass(normal,get("normal"));

		renderPass(defaultPass, get("outline"), backToFront );
		renderPass(defaultPass, get("default") );
		renderPass(defaultPass, get("alpha"), backToFront );
		renderPass(defaultPass, get("additive") );
	}
	
}