function Node_MK_Blinker(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Blinker";
	
	newActiveInput(6);
	
	////- Surfaces
	
	newInput(0, nodeValue_Surface( "Surface In", self));
	newInput(1, nodeValue_Surface( "Mask",       self));
	
	////- Blink
	
	newInput(2, nodeValueSeed(self));
	newInput(3, nodeValue_Slider(  "Amount",        self, 0.5));
	newInput(4, nodeValue_Palette( "Target Colors", self, [ ca_black ] ));
	newInput(5, nodeValue_Palette( "Light Colors",  self, [ ca_white ] ));
	newInput(7, nodeValue_Slider(  "Tolerance",     self, 0.1 ));
	
	////- Glow
	
	newInput( 8, nodeValue_Bool(   "Glow",     self, false));
	newInput( 9, nodeValue_Slider( "Size",     self, 4, [ 1, 8, 0.1 ] ));
	newInput(10, nodeValue_Slider( "Strength", self, 0.5 ));
		
	// inputs 11
		
	newOutput(0, nodeValue_Output( "Surface Out", self, VALUE_TYPE.surface, noone));
	newOutput(1, nodeValue_Output( "Light only",  self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 6, 
		["Surfaces", false], 0, 1, 
		["Blink",    false], 2, 3, 4, 5, 7, 
		["Glow",      true, 8], 9, 10, 
	]
	
	temp_surface = [ 0, 0, 0 ];
	
	surface_blur_init();
	
	static processData = function(_outData, _data, _output_index, _array_index) {
		var _surf = _data[0];
		var _mask = _data[1];
		var _seed = _data[2];
		var _amou = _data[3];
		var _trgC = _data[4];
		var _ligC = _data[5];
		var _tolr = _data[7];
		var _glow = _data[8];
		var _glsz = _data[9];
		var _glop = _data[10];
		
		if(!is_surface(_surf)) return _outData;
			
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) 
			temp_surface[i] = surface_verify(temp_surface[i], _sw, _sh);
		
		_outData[0] = surface_verify(_outData[0], _sw, _sh);
		_outData[1] = surface_verify(_outData[1], _sw, _sh);
		
		var _baseSurf  = _outData[0];
		var _lightData = _outData[1];
		
		surface_set_shader(temp_surface[0], sh_blink_extract);
			shader_set_palette(_trgC, "colorTarget", "colorTargetAmount");
			shader_set_f("tolerance", _tolr);
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		var rp     = sqrt(_sw * _sw + _sh * _sh);
		var ind    = 0;
		var _umask = is_surface(_mask);
		
		repeat(rp) {
			surface_set_shader(temp_surface[!ind], sh_blink_expand);
				shader_set_surface("mask", _mask);
				shader_set_f("dimension",  _sw, _sh);
				shader_set_i("useMask",    _umask);
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
		
		surface_set_shader(_lightData, noone, true, BLEND.over);
			draw_surface_safe(temp_surface[2]);
		surface_reset_shader();
		
		var lightBlur = _glow? surface_apply_gaussian(_lightData, _glsz, true, c_black, 1) : noone;
		
		surface_set_target(_baseSurf);
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
		
		return _outData;
	}
}