package ld45;


class CustomOutline extends hxsl.Shader {

	static var SRC = {

		@:import h3d.shader.BaseMesh;

		@param var size : Float;
		@param var distance : Float;
		@param var color : Vec4;

		function __init__vertex() {
			transformedPosition += transformedNormal * size;
		}

		function vertex() {
			projectedPosition.z -= distance * projectedPosition.w;
		}

		function fragment() {
			output.color = color;
		}

	};

}