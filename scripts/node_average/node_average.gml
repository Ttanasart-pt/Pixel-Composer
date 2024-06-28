function Node_Average(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Average";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 2] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 3] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 3;
		
	inputs[| 4] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(1); // inputs 5, 6, 
	
	input_display_list = [ 3, 4, 
		["Surfaces", false], 0, 1, 2, 5, 6, 
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Color", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, c_black);
	
	attribute_surface_depth();
	
	static step = function() {
		__step_mask_modifier();
	}
	
	static processData = function(_outData, _data, _output_index, _array_index) {
		var inSurf   = _data[0];
		var _outSurf = _outData[0];
		
		if(!is_surface(inSurf)) return [ _outSurf, c_black ];
		
		var lop  = ceil(log2(max(surface_get_width_safe(inSurf), surface_get_height_safe(inSurf))));
		var side = power(2, lop);
		var cc;
		
		if(side / 2 >= 1) {
			var _Surf = [ surface_create_valid(side, side), surface_create_valid(side, side) ];
			var _ind = 1;
			
			surface_set_shader(_Surf[0], noone);
				draw_surface_stretched_safe(inSurf, 0, 0, side, side);
			surface_reset_shader();
			
			for( var i = 0; i <= lop; i++ ) {
				surface_set_shader(_Surf[_ind], sh_average);
					shader_set_f("dimension", side);
					draw_surface_safe(_Surf[!_ind], 0, 0);
				surface_reset_shader();
				
				_ind = !_ind;
				side /= 2;
			}
			
			cc = surface_get_pixel(_Surf[!_ind], 0, 0);
			
			surface_free(_Surf[0]);
			surface_free(_Surf[1]);
		} else 
			cc = surface_get_pixel(inSurf, 0, 0);
		
		surface_set_target(_outSurf);
			draw_clear(cc);
		surface_reset_target();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[1], _data[2]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[4]);
		
		return [ _outSurf, cc ];
	}
}