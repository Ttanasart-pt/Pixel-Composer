function Node_Barrel_Distort(_x, _y, _group = noone) : Node_Shader_Processor(_x, _y, _group) constructor {
	name   = "Barrel Distort";
	shader = sh_barrel_distort;
	
	var i = shader_index;
	
	////- =Distort
	newInput(i+1, nodeValue_Vec2(    "Center",    [.5,.5] )).setUnitSimple().setShaderProp("center");
	newInput(i+0, nodeValue_Float(   "Intensity",   1.5   )).setShaderProp("intensity");
	newInput(i+2, nodeValue_Vec2(    "Scale",      [1,1]  )).setShaderProp("scale");
	
	////- =Advance
	newInput(i+3, nodeValue_EScroll( "Distance Methods", 0, [ "Cartesian", "Taxicap", "Max", "Min" ] )).setShaderProp("distanceMethod");
	
	array_append(input_display_list, [ 
		[ "Distort", false ], i+1, i+0, i+2, 
		[ "Advance", false ], i+3, 
	]);
	
	attribute_oversample();
	attribute_interpolation();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		PROCESSOR_OVERLAY_CHECK
		InputDrawOverlay(inputs[shader_index+1].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my));
		return w_hovering;
	}
	
}