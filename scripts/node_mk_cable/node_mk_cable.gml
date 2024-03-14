function Node_MK_Cable(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Cable";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Point 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Point 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 16, 16 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 0, 
		["Saber",		false], 1, 2, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _a = inputs[| 1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); active &= _a;
		var _a = inputs[| 2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); active &= _a;
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim  = _data[0];
		var _pnt1 = _data[1];
		var _pnt2 = _data[2];
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
		surface_reset_target();
		
		return _outSurf;
	}
}