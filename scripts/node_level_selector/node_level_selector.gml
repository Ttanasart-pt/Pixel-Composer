function Node_create_Level_Selector(_x, _y) {
	var node = new Node_Level_Selector(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Level_Selector(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "Level Selector";
	
	uniform_middle = shader_get_uniform(sh_level_selector, "middle");
	uniform_range  = shader_get_uniform(sh_level_selector, "range");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Middle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01]);
	
	inputs[| 2] = nodeValue(2, "Range",   self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01]);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	level_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _h = 128;
		var x0 = _x;
		var x1 = _x + _w;
		var y0 = _y;
		var y1 = _y + _h; 
		level_renderer.h = 128;
		
		var _middle = inputs[| 1].getValue();
		var _span   = inputs[| 2].getValue();
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
	});
	
	input_display_list = [
		level_renderer,
		["Level",	false],	0, 1, 2,
	];
	histogramInit();
	
	static onInspect = function() {
		if(array_length(current_data) > 0)
			histogramUpdate(current_data[0]);
	}
	
	static onValueUpdate = function(index) {
		if(index == 0) {
			update();
			if(array_length(current_data) > 0)
				histogramUpdate(current_data[0]);
		}
	}
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _middle = _data[1];
		var _range  = _data[2];
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_ADD
			
			shader_set(sh_level_selector);
			shader_set_uniform_f(uniform_middle, _middle);
			shader_set_uniform_f(uniform_range , _range );
			
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
			
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}