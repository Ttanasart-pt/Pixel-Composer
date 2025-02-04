function Node_Level(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Level";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Slider_Range("White in", self, [0, 1]));
	
	newInput(2, nodeValue_Slider_Range("Red in", self, [0, 1]));
	
	newInput(3, nodeValue_Slider_Range("Green in", self, [0, 1]));
	
	newInput(4, nodeValue_Slider_Range("Blue in", self, [0, 1]));
	
	newInput(5, nodeValue_Slider_Range("Alpha in", self, [0, 1]));
	
	newInput(6, nodeValue_Surface("Mask", self));
	
	newInput(7, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(8, nodeValue_Bool("Active", self, true));
		active_index = 8;
	
	newInput(9, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
		
	__init_mask_modifier(6); // inputs 10, 11
	
	newInput(12, nodeValue_Slider_Range("White out", self, [0, 1]));
	
	newInput(13, nodeValue_Slider_Range("Red out", self, [0, 1]));
	
	newInput(14, nodeValue_Slider_Range("Green out", self, [0, 1]));
	
	newInput(15, nodeValue_Slider_Range("Blue out", self, [0, 1]));
	
	newInput(16, nodeValue_Slider_Range("Alpha out", self, [0, 1]));
		
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	level_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _h = 128;
		var x0 = _x;
		var x1 = _x + _w;
		var y0 = _y;
		var y1 = _y + _h; 
		
		draw_set_color(COLORS.node_level_shade);
		var _wh = getInputData(1);
		var _wmin = min(_wh[0], _wh[1]);
		var _wmax = max(_wh[0], _wh[1]);
		
		draw_rectangle(x0, y0, x0 + max(0, _wmin) * _w, y1, false);
		draw_rectangle(x0 + min(1, _wmax) * _w, y0, x1, y1, false);
		
		for( var i = 0; i < 4; i++ ) {
			var _bx = x1 - 20 - i * 24;
			var _by = y0;
			
			if(buttonInstant(THEME.button_hide_fill, _bx, _by, 20, 20, _m, _hover, _focus) == 2) 
				histShow[i] = !histShow[i];
			draw_sprite_ui_uniform(THEME.circle, 0, _bx + 10, _by + 10, 1, COLORS.histogram[i], 0.5 + histShow[i] * 0.5);
		}
		
		if(histMax > 0)
			histogramDraw(x0, y1, _w, _h);

		draw_set_color(COLORS.node_level_outline);
		draw_rectangle(x0, y0, x1, y1, true);
		
		return _h;
	});
	
	input_display_list = [ 8, 9, 
		level_renderer,
		["Surfaces", true],	0, 6, 7, 10, 11,
		["Brightness",	false],	1, 12, 
		["Red",			false],	2, 13, 
		["Green",		false],	3, 14,  
		["Blue",		false],	4, 15, 
		["Alpha",		false],	5, 16, 
	];
	histogramInit();
	
	static onInspect = function() {
		if(array_length(current_data) > 0)
			histogramUpdate(current_data[0]);
	}
	
	static onValueFromUpdate = function(index) {
		if(index == 0) {
			doUpdate();
			if(array_length(current_data) > 0)
				histogramUpdate(current_data[0]);
		}
	}
	
	static step = function() {
		__step_mask_modifier();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {	
		var _wi = _data[1];
		var _ri = _data[2];
		var _gi = _data[3];
		var _bi = _data[4];
		var _ai = _data[5];
		
		var _wo = _data[12];
		var _ro = _data[13];
		var _go = _data[14];
		var _bo = _data[15];
		var _ao = _data[16];
		
		surface_set_shader(_outSurf, sh_level, true, BLEND.over);
			shader_set_2("lwi", _wi);
			shader_set_2("lri", _ri);
			shader_set_2("lgi", _gi);
			shader_set_2("lbi", _bi);
			shader_set_2("lai", _ai);
			
			shader_set_2("lwo", _wo);
			shader_set_2("lro", _ro);
			shader_set_2("lgo", _go);
			shader_set_2("lbo", _bo);
			shader_set_2("lao", _ao);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[6], _data[7]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[9]);
		
		return _outSurf;
	}
}
