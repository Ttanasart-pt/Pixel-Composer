function Node_Voronoi_Extra(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Extra Voronoi";
	shader = sh_voronoi_extra;
	
	newInput(1, nodeValue_Vec2("Position", [ 0, 0 ]))
		.setUnitRef(function(index) { return getDimension(index); });
		addShaderProp(SHADER_UNIFORM.float, "position");
		
	newInput(2, nodeValue_Vec2("Scale", [ 4, 4 ]));
		addShaderProp(SHADER_UNIFORM.float, "scale");
				
	newInput(3, nodeValueSeed());
		addShaderProp(SHADER_UNIFORM.float, "seed");
				
	newInput(4, nodeValue_Float("Progress", 0))
		addShaderProp(SHADER_UNIFORM.float, "progress");
				
	newInput(5, nodeValue_Enum_Scroll("Mode",  0, [ "Block", "Triangle" ]));
		addShaderProp(SHADER_UNIFORM.integer, "mode");
	
	newInput(6, nodeValue_Float("Parameter A", 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01 ] });
		addShaderProp(SHADER_UNIFORM.float, "paramA");
		
	newInput(7, nodeValue_Rotation("Rotation", 0));
		addShaderProp(SHADER_UNIFORM.float, "rotation");
			
	newInput(8, nodeValue_Surface("Mask"));
	
	input_display_list = [
		["Output", 	 true],	0, 8, 
		["Noise",	false],	5, 1, 7, 2, 4, 6, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		return w_hovering;
	}
}