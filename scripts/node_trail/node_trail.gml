function Node_create_Trail(_x, _y) {
	var node = new Node_Trail(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Trail(_x, _y) : Node_Processor(_x, _y) constructor {
	name		= "Trail";
	use_cache   = true;
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Max life",   self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 3);
	inputs[| 2] = nodeValue(2, "Step",       self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
	inputs[| 3] = nodeValue(3, "Alpha decrease",	self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 4] = nodeValue(4, "Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, BLEND_TYPES );
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	input_display_list = [
		["Trail settings",	false], 0, 1, 2, 4, 3
	];
	
	temp_surf = [ surface_create(1, 1), surface_create(1, 1) ];
	
	static process_data = function(_outSurf, _data, _output_index) {
		if(!inputs[| 0].value_from) 
			return _outSurf;
		if(array_length(cached_output) != ANIMATOR.frames_total + 1)
			return _outSurf
		
		for(var i = 0; i < 2; i++) {
			if(!is_surface(temp_surf[i])) temp_surf[i] = surface_create(surface_get_width(_outSurf), surface_get_height(_outSurf));
			else surface_size_to(temp_surf[i], surface_get_width(_outSurf), surface_get_height(_outSurf));
			
			surface_set_target(temp_surf[i]);
			draw_clear_alpha(0, 0);
			surface_reset_target();
		}
		
		var _life  = _data[1];
		var _step  = _data[2];
		var _alpha = _data[3];
		var _blend = _data[4];
		
		var aa = 1;
		var res_index = 0;
		var st_frame  = floor(ANIMATOR.current_frame / _step);
		
		for(var i = _life; i >= 0; i--) {
			var frame = clamp(st_frame - i * _step, 0, ANIMATOR.frames_total);
			var bg = i % 2;
			var fg = (i + 1) % 2;
			aa = max(aa - _alpha, 0);
			
			surface_set_target(temp_surf[bg]);
				if(i == _life)
					draw_surface_safe(_data[0], 0, 0);
				else if(is_surface(cached_output[frame]))
					draw_surface_blend(temp_surf[fg], cached_output[frame], _blend, aa);
			surface_reset_target();
			
			res_index = bg;
		}
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_ADD
			draw_surface_safe(temp_surf[res_index], 0, 0);
		BLEND_NORMAL
		surface_reset_target();
		
		cacheCurrentFrame(_data[0]);
		
		return _outSurf;
	}
}