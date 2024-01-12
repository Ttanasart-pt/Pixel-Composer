function Node_MK_Blinker(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Blinker";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 2] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, seed_random())
	
	inputs[| 3] = nodeValue("Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
		
	inputs[| 4] = nodeValue("Target Colors", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, [ c_black ] )
		.setDisplay(VALUE_DISPLAY.palette);
		
	inputs[| 5] = nodeValue("Light Colors", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, [ c_white ] )
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 6] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 6;
		
	inputs[| 7] = nodeValue("Tolerance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1 )
		.setDisplay(VALUE_DISPLAY.slider);
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 6, 
		["Surfaces",	false], 0, 1, 
		["Blink",		false], 2, 3, 4, 5, 7, 
	]
	
	temp_surface = [ surface_create( 1, 1 ), surface_create( 1, 1 ), surface_create( 1, 1 ) ];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		var _mask = _data[1];
		var _seed = _data[2];
		var _amou = _data[3];
		var _trgC = _data[4];
		var _ligC = _data[5];
		var _tolr = _data[7];
		
		if(!is_surface(_surf)) return _outSurf;
		
		var _sw = surface_get_width_safe(_outSurf);
		var _sh = surface_get_height_safe(_outSurf);
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) 
			temp_surface[i] = surface_verify(temp_surface[i], _sw, _sh);
		
		surface_set_shader(temp_surface[0], sh_blink_extract);
			shader_set_palette(_trgC, "colorTarget", "colorTargetAmount");
			shader_set_f("tolerance", _tolr);
		
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		var rp  = sqrt(_sw * _sw + _sh * _sh);
		var ind = 0;
		var _umask = is_surface(_mask);
		
		repeat(rp) {
			surface_set_shader(temp_surface[!ind], sh_blink_expand);
				shader_set_f("dimension",  _sw, _sh);
				shader_set_i("useMask",    _umask);
				shader_set_surface("mask", _mask);
				
				draw_surface(temp_surface[ind], 0, 0);
			surface_reset_shader();
			
			ind = !ind;
		}
		
		surface_set_shader(temp_surface[2], sh_blink_replace);
			shader_set_f("seed",  _seed);
			shader_set_f("ratio", _amou);
			shader_set_palette(_ligC);
			
			draw_surface_safe(temp_surface[ind]);
		surface_reset_shader();
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			BLEND_OVERRIDE
				
				draw_surface(_surf, 0, 0);
			BLEND_ALPHA_MULP
				
				draw_surface(temp_surface[2], 0, 0);
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}