function Node_Solid(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Solid";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 2] = nodeValue("Empty", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 3] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 4] = nodeValue("Use mask dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Output",	false], 0, 3, 4,
		["Solid",	false], 1, 2,
	];
	
	attribute_surface_depth();
		
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _col = _data[1];
		var _emp = _data[2];
		var _msk = _data[3];
		var _msd = _data[4];
		
		inputs[| 4].setVisible(is_surface(_msk));
		if(is_surface(_msk) && _msd)
			_dim = [ surface_get_width_safe(_msk), surface_get_height_safe(_msk) ];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		if(_emp) {
			surface_set_target(_outSurf);
				DRAW_CLEAR
			surface_reset_target();
			return _outSurf;
		}
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			shader_set(sh_solid);
			if(is_surface(_msk))
				draw_surface_stretched_ext(_msk, 0, 0, _dim[0], _dim[1], _col, 1);
			else
				draw_sprite_stretched_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], _col, 1);
			shader_reset();
		surface_reset_target();
		
		return _outSurf;
	}
}