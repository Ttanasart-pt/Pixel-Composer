function Node_MK_Fracture(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Fracture";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Subdivision", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 4, 4 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 0, 
		["Fracture",	false], 1, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			
		surface_reset_target();
		
		return _outSurf;
	}
}