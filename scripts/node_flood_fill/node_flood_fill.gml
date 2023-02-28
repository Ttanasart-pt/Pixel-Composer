function Node_Flood_Fill(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Flood Fill";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0)
		.rejectArray();
		
	inputs[| 1] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 2] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 3] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 3;
		
	inputs[| 4] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 5] = nodeValue("Colors", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black )
	
	inputs[| 6] = nodeValue("Threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 7] = nodeValue("Diagonal", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue("Surface out",	self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 3,
		["Surface",	 false], 0, 1, 2, 
		["Fill",	 false], 4, 6, 5, 7, 
	]
	
	temp_surface = [ surface_create(1, 1), surface_create(1, 1) ];
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 4].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var inSurf = _data[0];
		if(!is_surface(inSurf)) return _outSurf;
		
		var _pos = _data[4];
		var _col = _data[5];
		var _thr = _data[6];
		var _dia = _data[7];
		
		var _filC = surface_getpixel_ext(inSurf, _pos[0], _pos[1]);
		
		var sw = surface_get_width(inSurf);
		var sh = surface_get_height(inSurf);
		
		for( var i = 0; i < array_length(temp_surface); i++ )
			temp_surface[i] = surface_verify(temp_surface[i], sw, sh);
		
		surface_set_target(temp_surface[0]);
			draw_clear_alpha(0, 0);
			
			shader_set(sh_flood_fill_thres);
			shader_set_f(sh_flood_fill_thres, "color", colaToVec4(_filC));
			shader_set_f(sh_flood_fill_thres, "thres", _thr);
				BLEND_OVERRIDE
				draw_surface(inSurf, 0, 0);
				BLEND_NORMAL
			shader_reset();
			
			BLEND_OVERRIDE
			draw_set_color(c_red);
			draw_point(_pos[0] - 1, _pos[1] - 1);
			BLEND_NORMAL
		surface_reset_target();
		
		var ind = 0;
		var it  = sw + sh;
		repeat(it) {
			ind = !ind;
			
			surface_set_target(temp_surface[ind]);
			draw_clear_alpha(0, 0);
			
			shader_set(sh_flood_fill_it);
			shader_set_f(sh_flood_fill_it, "dimension", [ sw, sh ]);
			shader_set_i(sh_flood_fill_it, "diagonal", _dia);
				BLEND_OVERRIDE
				draw_surface(temp_surface[!ind], 0, 0);
				BLEND_NORMAL
			shader_reset();
			surface_reset_target();
		}
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		
		shader_set(sh_flood_fill_replace);
		shader_set_f(sh_flood_fill_replace, "color", colToVec4(_col));
		shader_set_surface(sh_flood_fill_replace, "mask", temp_surface[ind]);
			BLEND_OVERRIDE
			draw_surface(inSurf, 0, 0);
			BLEND_NORMAL
		shader_reset();
		surface_reset_target();
		
		_outSurf = mask_apply(_data[0], _outSurf, _data[1], _data[2]);
		return _outSurf;
	}
}
