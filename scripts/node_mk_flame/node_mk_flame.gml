function Node_MK_Flame(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "MK Flame";
	update_on_frame = true;
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Rotation("Direction", self, 45));
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 0,  
		["Shape",	false], 1, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
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