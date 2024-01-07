function Node_MK_Flame(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "MK Flame";
	update_on_frame = true;
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 45)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 0,  
		["Shape",	false], 1, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	static step = function() { #region
		
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _dim  = _data[0];
		var _dirr = _data[1];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			
		surface_reset_target();
		
		return _outSurf;
	} #endregion
}