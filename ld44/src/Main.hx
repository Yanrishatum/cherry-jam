import scenes.RaceScene;
import util.DebugDisplay;
import hxd.Res;
import hxd.res.ManifestLoader;
import h2d.ui.ManifestProgress;

import game.UpdateObject;

class Main extends hxd.App {
	
	public static var updateList:Array<IUpdateObject> = new Array();
	#if js
	var loader:ManifestLoader;
	#end
	
	public static var inst:Main;
	
	static function main() {
		new Main();
	}
	
	override private function init()
	{
		inst = this;
		#if hl
		if (sys.FileSystem.exists("res/data.cdb"))
		{
			hxd.Res.loader = new hxd.res.Loader(new hxd.fs.LocalFileSystem("res"));
		}
		else
			hxd.Res.initLocal();
		_init();
		#else
		loader = hxd.fs.ManifestBuilder.initManifest();
		new util.DexLoader(loader, _init, s2d);
		// var ld = new ManifestProgress(loader, _init, s2d);
		// ld.start();
		// TODO
		#end
	}
	
	function _init()
	{
		engine.backgroundColor = 0xff333344;
		Res.data.watch(updateDB);
		updateDB();
		util.DebugDisplay.init();
		// DebugDisplay.beginGroup("Debug", false);
		// DebugDisplay.addButton("test", setMap.bind("test.tmx", 0));
		// DebugDisplay.addButton("lvl1", setMap.bind("tilemap_01.tmx", 0));
		// DebugDisplay.addButton("lvl2", setMap.bind("tilemap_01.tmx", 1));
		// DebugDisplay.addButton("Car: Emo", reloadCar.bind(CarsKind.emo));
		// DebugDisplay.addButton("Car: Rider", reloadCar.bind(CarsKind.rider));
		// DebugDisplay.addButton("Car: Stroker", reloadCar.bind(CarsKind.stroker));
		// DebugDisplay.endGroup();
		setScene2D(new scenes.MenuScene());
		// setMap("test.tmx", 1);
	}
	
	public function setMap(file:String, layer:Int)
	{
		setScene2D(new scenes.RaceScene(hxd.Res.load("maps/" + file), layer));
	}
	
	function reloadCar(car:CarsKind)
	{
		cast(s2d, RaceScene).debug_changeCar(util.Data.cars.get(car));
	}
	
	function updateDB()
	{
		util.Data.load(Res.data.entry.getText());
		try {
			reloadCar(@:privateAccess cast(s2d, RaceScene).player.stats.ref.name);
		} catch (e:Dynamic) {}
	}
	
	override private function update(dt:Float)
	{
		for (o in updateList)
		{
			o.update();
		}
	}
	
}
