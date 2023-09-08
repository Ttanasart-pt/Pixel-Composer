function Node_Average(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
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
		["Output", 	 false], 0, 1, 2, 
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Color", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, c_black);
	
	attribute_surface_depth();

	colors = [];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var inSurf = _data[0];
		if(!is_surface(inSurf)) return _outSurf;
		
		if(_output_index == 1)
			return array_safe_get(colors, _array_index);
			
		var side = max(surface_get_width_safe(inSurf), surface_get_height_safe(inSurf));
		var lop  = ceil(log2(side));
		var cc;
		side = power(2, lop);
		
		if(side / 2 >= 1) {
			var _Surf = [ surface_create_valid(side, side), surface_create_valid(side, side) ];
			var _ind = 1;
			
			surface_set_target(_Surf[0]);
			DRAW_CLEAR
			BLEND_OVERRIDE;
			draw_surface_stretched_safe(inSurf, 0, 0, side, side);
			BLEND_NORMAL;
			surface_reset_target();
			
			shader_set(sh_average);
			for( var i = 0; i <= lop; i++ ) {
				shader_set_uniform_f(uniform_dim, side);
				
				surface_set_target(_Surf[_ind]);
				DRAW_CLEAR
				draw_surface_safe(_Surf[!_ind], 0, 0);
				surface_reset_target();
				
				_ind = !_ind;
				side /= 2;
			}
			shader_reset();
			
			cc = surface_get_pixel(_Surf[!_ind], 0, 0);
			
			surface_free(_Surf[0]);
			surface_free(_Surf[1]);
		} else 
			cc = surface_get_pixel(inSurf, 0, 0);
		
		surface_set_target(_outSurf);
		draw_clear(cc);
		surface_reset_target();
		
		_outSurf = mask_apply(_data[0], _outSurf, _data[1], _data[2]);
		colors[_array_index] = cc;
		
		return _outSurf;
	}
}