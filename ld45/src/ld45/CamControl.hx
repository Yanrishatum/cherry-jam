package ld45;

import h3d.prim.Cube;
import h3d.mat.Material;
import h3d.prim.Plane2D;
import h3d.scene.Mesh;
import h3d.prim.Sphere;
import hxd.Res;
import h3d.scene.TileSprite;
import h3d.scene.RenderContext;
import h3d.Camera;
import hxd.Key;
import hxd.Event;
import h3d.scene.Object;

class HackPos extends hxsl.Shader {
	static var SRC = {
		@:import h3d.shader.BaseMesh;
		
		@param var size:Vec2;
		
		function vertex()
		{
			relativePosition.xy += camera.position.xy - vec2(0, size.y / 1.2);
			relativePosition.z = camera.position.z - 100;
			// projectedPosition = vec4(transformedPosition, 1) * camera.viewProj;
		}
		
	}
}

class CamControl extends Object {
  
  var camera:Camera;
  var detached:Bool = false;
	
	public function new(?parent)
	{
		super(parent);
		
		var tx = Res.textures.background.toTexture();
		var s = 0.09;
		var c = new Cube(tx.width * s, tx.height*s, 1, true);
		c.addNormals();
		c.addUVs();
		c.unindex();
		var mesh = new Mesh(c, Material.create(tx), this);
		mesh.material.shadows = false;
		var shader = new HackPos();
		shader.size.set(tx.width*s, tx.height*s);
		mesh.material.mainPass.addShader(shader);
		
	}
  
  override function onAdd()
  {
    super.onAdd();
    camera = getScene().camera;
		hxd.Window.getInstance().addEventTarget(handleCamera);
  }
  
  override function onRemove()
  {
    super.onRemove();
		hxd.Window.getInstance().removeEventTarget(handleCamera);
  }
  
  override function sync(ctx:RenderContext)
  {
		// if (Key.isReleased(Key.T))
		// {
		// 	// var cam = s3d.find( (o) -> Std.is(o, CameraController) ? o : null);
		// 	trace(s3d.camera.pos, s3d.camera.target, s3d.camera.up);
		// }
		// var mx = 0, my = 0;
		// if (Key.isDown(Key.A) || Key.isDown(Key.LEFT)) mx--;
		// if (Key.isDown(Key.D) || Key.isDown(Key.RIGHT)) mx++;
		// if (Key.isDown(Key.W) || Key.isDown(Key.UP)) my--;
		// if (Key.isDown(Key.S) || Key.isDown(Key.DOWN)) my++;
		// if (mx != 0 || my != 0)
		// {
		// 	panCamera(-mx*10, -my*10);
		// }
		if (GameMap.current != null && !detached)
		{
			var p = GameMap.current.player;
      var dx = p.x - camera.target.x;
      var dy = p.y - camera.target.y;
			camera.pos.x += dx;
			camera.pos.y += dy;
			camera.target.x += dx;
			camera.target.y += dy;
		}
		if (Key.isDown(Key.F)) trace(camera.pos.z);
    super.sync(ctx);
  }
  
	var camRelX:Float;
	var camRelY:Float;
	function handleCamera(e:Event)
	{
		switch (e.kind)
		{
			// case EMove:
			// 	if (Key.isDown(Key.MOUSE_RIGHT))
			// 	{
			// 		panCamera(e.relX - camRelX,e.relY - camRelY);
					
			// 		camRelX = e.relX;
			// 		camRelY = e.relY;
			// 	}
			// case EPush:
			// 	if (e.button == Key.MOUSE_RIGHT)
			// 	{
			// 		camRelX = e.relX;
			// 		camRelY = e.relY;
			// 	}
			case EWheel:
				if (e.wheelDelta > 0)
				{
					var d = e.wheelDelta;
					while (d-- > 0) {
						if (camera.pos.z < 28.5) break;
						camera.forward(2);
					}
				}
				else
				{
					var d = -e.wheelDelta;
					while (d-- > 0) {
						if (camera.pos.z > 95) break;
						camera.backward(2);
					}
				}
			default:
		}
	}
	
	function panCamera(rx:Float, ry:Float)
	{
		var c = camera;
		
		final sensitivity = 0.001 * camera.pos.y * 15 / 25;//0.05;
		
		// trace(e.relX, e.relY, e.relZ);
		var dx = rx * sensitivity;
		var dy = ry * sensitivity;
		c.pos.x -= dx;
		c.pos.y -= dy;
		c.target.x -= dx;
		c.target.y -= dy;
	}
}