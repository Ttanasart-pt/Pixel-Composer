function Node_Level_Selector(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Level Selector";
	
	newActiveInput(5);
	newInput(6, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(3, nodeValue_Surface( "Mask"       ));
	newInput(4, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(3, 7); // inputs 7, 8, 
	
	////- =Level
	
	newInput( 1, nodeValue_Slider( "Midpoint",    0 )).setHotkey("M").setMappable(9);
	newInput( 2, nodeValue_Slider( "Range",      .1 )).setHotkey("R").setMappable(10);
	newInput(12, nodeValue_Slider( "Smoothness",  0 ));
	
	////- =Output
	
	newInput(11, nodeValue_Bool( "Keep Original", false ));
	
	// input 13
		
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	level_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
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
	
	input_display_list = [ 5, 6, 
		level_renderer,
		["Surfaces", true],	0, 3, 4, 7, 8, 
		["Level",	false],	1, 9, 2, 10, 12, 
		["Output",	false],	11, 
	];
	histogramInit();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _cx, _cy - ui(16), _s, _mx, _my, _snx, _sny, 0, _dim[0] / 2));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _cx, _cy + ui(16), _s, _mx, _my, _snx, _sny, 0, _dim[0] / 2));
		
		return w_hovering;
	}
	
	static onInspect = function() {
		if(array_length(current_data) > 0)
			histogramUpdate(current_data[0]);
	}
	
	static onValueFromUpdate = function(index) {
		if(index == 0) {
			update();
			if(array_length(current_data) > 0)
				histogramUpdate(current_data[0]);
		}
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		
		surface_set_shader(_outSurf, sh_level_selector);
			shader_set_f_map("middle", _data[1], _data[ 9], inputs[1]);
			shader_set_f_map("range" , _data[2], _data[10], inputs[2]);
			shader_set_f("smoothness", _data[12]);
			shader_set_i("keep", _data[11]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[6]);
		
		return _outSurf;
	}
}