function Node_Interlaced(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Interlace";
	
	update_on_frame    = true;
	use_cache          = CACHE_USE.manual;
	clearCacheOnChange = false;
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Bool("Active", self, true));
		active_index = 1;
	
	newInput(2, nodeValue_Surface("Mask", self));
	
	newInput(3, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(4, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(2); // inputs 5, 6
	
	newInput(7, nodeValue_Enum_Button("Axis", self,  0, [ "X", "Y" ]));
	
	newInput(8, nodeValue_Float("Size", self, 1));
	
	newInput(9, nodeValue_Bool("Invert", self, false));
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 1, 
		["Surface", false], 0, 2, 3, 4, 
		["Effects", false], 7, 8, 9, 
	];
	
	attribute_surface_depth();
	
	insp2UpdateTooltip = "Clear cache";
	insp2UpdateIcon    = [ THEME.cache, 0, COLORS._main_icon ];
	
	static onInspector2Update = function() { clearCache(); }
	
	static step = function() {
		__step_mask_modifier();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		var _axis = _data[7];
		var _size = _data[8];
		var _invt = _data[9];
		
		var _dim  = surface_get_dimension(_surf);
		var _prev = array_safe_get_fast(cached_output, CURRENT_FRAME - 1, noone);
		
		surface_set_shader(_outSurf, sh_interlaced);
			shader_set_i("useSurf", is_surface(_prev));
			shader_set_surface("prevFrame", _prev);
			
			shader_set_2("dimension", _dim);
			shader_set_i("axis",      _axis);
			shader_set_i("invert",    _invt);
			shader_set_f("size",      _size);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		cacheCurrentFrame(_surf);
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[2], _data[3]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[4]);
		
		return _outSurf;
	}
}