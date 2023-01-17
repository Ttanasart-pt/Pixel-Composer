function Node_Average(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Average";
	
	shader = sh_average;
	uniform_dim = shader_get_uniform(shader, "dimension");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var inSurf = _data[0];
		if(!is_surface(inSurf)) return _outSurf;
		
		var side = max(surface_get_width(inSurf), surface_get_height(inSurf));
		var lop = ceil(log2(side));
		var cc;
		side = power(2, lop);
		
		if(side / 2 >= 1) {
			var _Surf = [ surface_create(side, side), surface_create(side / 2, side / 2) ];
			var _ind = 1;
		
			surface_set_target(_Surf[0]);
			draw_clear_alpha(0, 0);
			BLEND_OVERRIDE
			draw_surface(inSurf, 0, 0);
			BLEND_NORMAL
			surface_reset_target();
			
			gpu_set_tex_filter(true);
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
		} else 
			cc = surface_getpixel(inSurf, 0, 0);
		
		surface_set_target(_outSurf);
		draw_clear(cc);
		surface_reset_target();
		
		return _outSurf;
	}
}