function Node_Level_Selector(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Level Selector";
	
	inputs[| 0] = nodeValue_Surface("Surface in", self);
	
	inputs[| 1] = nodeValue_Float("Midpoint", self, 0)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(9);
	
	inputs[| 2] = nodeValue_Float("Range",   self, 0.1)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(10);
	
	inputs[| 3] = nodeValue_Surface("Mask", self);
	
	inputs[| 4] = nodeValue_Float("Mix", self, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 5] = nodeValue_Bool("Active", self, true);
		active_index = 5;
	
	inputs[| 6] = nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(3); // inputs 7, 8, 
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[|  9] = nodeValueMap("Midpoint map", self);
	
	inputs[| 10] = nodeValueMap("Range map", self);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 11] = nodeValue_Bool("Keep Original", self, false);
	
	outputs[| 0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	level_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { #region
		var _h = 128;
		var x0 = _x;
		var x1 = _x + _w;
		var y0 = _y;
		var y1 = _y + _h; 
		level_renderer.h = 128;
		
		var _middle = getInputData(1);
		var _span   = getInputData(2);
		
		if(is_array(_middle)) _middle = array_safe_get_fast(_middle, 0);
		if(is_array(_span))   _span   = array_safe_get_fast(_span,   0);
		
		var _min    = _middle - _span;
		var _max    = _middle + _span;
		
		draw_set_color(COLORS.node_level_shade);
		draw_rectangle(x0, y0, x0 + max(0, _min) * _w, y1, false);
		draw_rectangle(x0 + min(1, _max) * _w, y0, x1, y1, false);
		
		for( var i = 0; i < 4; i++ ) {
			var _bx = x1 - 20 - i * 24;
			var _by = y0;
			
			if(buttonInstant(THEME.button_hide, _bx, _by, 20, 20, _m, _focus, _hover) == 2) 
				histShow[i] = !histShow[i];
			draw_sprite_ui_uniform(THEME.circle, 0, _bx + 10, _by + 10, 1, COLORS.histogram[i], 0.5 + histShow[i] * 0.5);
		}
		
		if(histMax > 0)
			histogramDraw(x0, y1, _w, _h);

		draw_set_color(COLORS.node_level_outline);
		draw_rectangle(x0, y0, x1, y1, true);
		
		return _h;
	}); #endregion
	
	input_display_list = [ 5, 6, 
		level_renderer,
		["Surfaces", true],	0, 3, 4, 7, 8, 
		["Level",	false],	1, 9, 2, 10, 
		["Output",	false],	11, 
	];
	histogramInit();
	
	static onInspect = function() { #region
		if(array_length(current_data) > 0)
			histogramUpdate(current_data[0]);
	} #endregion
	
	static onValueFromUpdate = function(index) { #region
		if(index == 0) {
			update();
			if(array_length(current_data) > 0)
				histogramUpdate(current_data[0]);
		}
	} #endregion
	
	static step = function() { #region
		__step_mask_modifier();
		
		inputs[| 1].mappableStep();
		inputs[| 2].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		
		surface_set_shader(_outSurf, sh_level_selector);
			shader_set_f_map("middle", _data[1], _data[ 9], inputs[| 1]);
			shader_set_f_map("range" , _data[2], _data[10], inputs[| 2]);
			shader_set_i("keep", _data[11]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[6]);
		
		return _outSurf;
	} #endregion
}