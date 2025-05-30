function Node_Voronoi_Extra(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Extra Voronoi";
	shader = sh_voronoi_extra;
	
	////- =Output
	
	newInput(8, nodeValue_Surface("Mask"));
	
	////- =Noise
	
	newInput(3, nodeValueSeed()).setShaderProp("seed");
	newInput(5, nodeValue_Enum_Scroll( "Mode",         0, [ "Block", "Triangle" ])).setShaderProp("mode");
	newInput(4, nodeValue_Float(       "Progress",     0 )).setShaderProp("progress");
	newInput(6, nodeValue_Slider(      "Parameter A",  0, [ -1, 1, 0.01 ])).setShaderProp("paramA");
	
	////- =Transform
	
	newInput(1, nodeValue_Vec2(     "Position",  [0,0] )).setShaderProp("position").setUnitRef(function(i) /*=>*/ {return getDimension(i)});
	newInput(7, nodeValue_Rotation( "Rotation",   0    )).setShaderProp("rotation");
	newInput(2, nodeValue_Vec2(     "Scale",     [4,4] )).setShaderProp("scale");
	
	input_display_list = [
		["Output",      true], 0, 8, 
		["Noise",      false], 3, 5, 4, 6, 
		["Transform",  false], 1, 7, 2,
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		return w_hovering;
	}
}