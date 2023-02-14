function Node_Average(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Average";
	
	shader = sh_average;
	uniform_dim = shader_get_uniform(shader, "dimension");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 2] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 3] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 3;
		
	input_display_list = [ 3,
		["Surface",	 false], 0, 1, 2, 
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var inSurf = _data[0];
		if(!is_surface(inSurf)) return _outSurf;
		
		var side = max(surface_get_width(inSurf), surface_get_height(inSurf));
		var lop = ceil(log2(side));
		var cc;
		side = power(2, lop);
		
		if(side / 2 >= 1) {
			var _Surf = [ surface_create_valid(side, side), surface_create_valid(side / 2, side / 2) ];
			var _ind = 1;
			
			gpu_set_tex_filter(true);
			
			surface_set_target(_Surf[0]);
			draw_clear_alpha(0, 0);
			BLEND_OVERRIDE;
			draw_surface_stretched(inSurf, 0, 0, side, side);
			BLEND_NORMAL;
			surface_reset_target();
			
			for( var i = 0; i < lop; i++ ) {
				surface_set_target(_Surf[_ind]);
				draw_clear_alpha(0, 0);
				draw_surface_ext(_Surf[!_ind], 0, 0, 0.5, 0.5, 0, c_white, 1);
				surface_reset_target();
			
				if(side / 4 >= 1) surface_resize(_Surf[!_ind], side / 4, side / 4);
				_ind = !_ind;
				side /= 2;
			}
			gpu_set_tex_filter(false);
			cc = surface_getpixel(_Surf[!_ind], 0, 0);
			
			surface_free(_Surf[0]);
			surface_free(_Surf[1]);
		} else 
			cc = surface_getpixel(inSurf, 0, 0);
		
		surface_set_target(_outSurf);
		draw_clear(cc);
		surface_reset_target();
		
		_outSurf = mask_apply(_data[0], _outSurf, _data[1], _data[2]);
		
		return _outSurf;
	}
}