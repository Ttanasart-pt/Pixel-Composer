function Node_Time_Remap(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name      = "Time Remap";
	use_cache = CACHE_USE.manual;
	update_on_frame = true;
	
	newInput(0, nodeValue_Surface("Surface in", self))
		.rejectArray();
	
	newInput(1, nodeValue_Surface("Map", self))
		.rejectArray();
	
	newInput(2, nodeValue_Int("Max life",   self, 3))
		.rejectArray();
	
	newInput(3, nodeValue_Bool("Loop", self, false))
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		["Surfaces", false], 0, 1, 
		["Remap",	 false], 2, 3,
	]
	
	attribute_surface_depth();
	
	static update = function(frame = CURRENT_FRAME) {
		var _inSurf  = getInputData(0);
		var _map     = getInputData(1);
		var _life    = getInputData(2);
		var _loop    = getInputData(3);
		cacheCurrentFrame(_inSurf);
		
		var _surf  = outputs[0].getValue();
		_surf = surface_verify(_surf, surface_get_width_safe(_inSurf), surface_get_height_safe(_inSurf), attrDepth());
		outputs[0].setValue(_surf);
		
		var ste = 1 / _life;
		
		surface_set_shader(_surf, sh_time_remap);
		shader_set_surface("map", _map);
		
		for(var i = 0; i <= _life; i++) {
			var _frame = CURRENT_FRAME - i;
			if(_loop) _frame = _frame < 0? TOTAL_FRAMES - 1 + _frame : _frame;
			else      _frame = clamp(_frame, 0, TOTAL_FRAMES - 1);
			
			var s = array_safe_get_fast(cached_output, _frame);
			if(!is_surface(s)) continue;
			
			shader_set_f("vMin", i * ste);	
			shader_set_f("vMax", i * ste + ste);	
			draw_surface_safe(s);
		}
		
		surface_reset_shader();
	}
}