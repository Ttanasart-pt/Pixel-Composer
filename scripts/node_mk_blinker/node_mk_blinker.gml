function Node_MK_Blinker(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Blinker";
	batch_output = false;
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Surface("Mask", self));
	
	newInput(2, nodeValueSeed(self));
	
	newInput(3, nodeValue_Float("Amount", self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider);
		
	newInput(4, nodeValue_Palette("Target Colors", self, [ c_black ] ));
		
	newInput(5, nodeValue_Palette("Light Colors", self, [ c_white ] ));
	
	newInput(6, nodeValue_Bool("Active", self, true));
		active_index = 6;
		
	newInput(7, nodeValue_Float("Tolerance", self, 0.1 ))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(8, nodeValue_Bool("Glow", self, false));
	
	newInput(9, nodeValue_Float("Size", self, 4 ))
		.setDisplay(VALUE_DISPLAY.slider, { range : [ 1, 8, 0.1 ] });
	
	newInput(10, nodeValue_Float("Strength", self, 0.5 ))
		.setDisplay(VALUE_DISPLAY.slider);
		
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
		
	newOutput(1, nodeValue_Output("Light only", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 6, 
		["Surfaces", false], 0, 1, 
		["Blink",	 false], 2, 3, 4, 5, 7, 
		["Glow",	  true, 8], 9, 10, 
	]
	
	temp_surface = [ surface_create( 1, 1 ), surface_create( 1, 1 ), surface_create( 1, 1 ) ];
	light_only   = [];
	
	surface_blur_init();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		if(_output_index == 1) return light_only[_array_index];
		
		var _surf = _data[0];
		var _mask = _data[1];
		var _seed = _data[2];
		var _amou = _data[3];
		var _trgC = _data[4];
		var _ligC = _data[5];
		var _tolr = _data[7];
		var _glow  = _data[8];
		var _glsz = _data[9];
		var _glop = _data[10];
		
		if(!is_surface(_surf)) return _outSurf;
		
		var _sw = surface_get_width_safe(_outSurf);
		var _sh = surface_get_height_safe(_outSurf);
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) 
			temp_surface[i] = surface_verify(temp_surface[i], _sw, _sh);
		light_only[_array_index] = surface_verify(array_safe_get_fast(light_only, _array_index), _sw, _sh);
		
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
				
				draw_surface_safe(temp_surface[ind]);
			surface_reset_shader();
			
			ind = !ind;
		}
		
		surface_set_shader(temp_surface[2], sh_blink_replace);
			shader_set_f("seed",  _seed);
			shader_set_f("ratio", _amou);
			shader_set_palette(_ligC);
			
			draw_surface_safe(temp_surface[ind]);
		surface_reset_shader();
		
		surface_set_target(light_only[_array_index]);
			DRAW_CLEAR
			BLEND_OVERRIDE
				draw_surface_safe(temp_surface[2]);
			BLEND_NORMAL
		surface_reset_target();
		
		if(_glow) var lightBlur = surface_apply_gaussian(light_only[_array_index], _glsz, true, c_black, 1);
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			BLEND_OVERRIDE
				draw_surface_safe(_surf);
			
			if(_glow) {
				BLEND_ADD
					draw_surface_ext(lightBlur, 0, 0, 1, 1, 0, c_white, _glop);
			}
			
			BLEND_ALPHA_MULP
				draw_surface_safe(temp_surface[2]);
				
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}