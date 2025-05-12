enum WAVETABLE_FN {
	sine,
	square,
	tri,
	saw,
}

function Node_Fn_WaveTable(_x, _y, _group = noone) : Node_Fn(_x, _y, _group) constructor {
	name = "WaveTable";
	
	newInput(inl + 0, nodeValue_Float("Pattern", self, 0 ));
		
	newInput(inl + 1, nodeValue_Vec2("Range", self, [ 0, 1 ]));
	
	newInput(inl + 2, nodeValue_Float("Frequency", self, 2 ))
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 8, 0.01] });
	
	newInput(inl + 3, nodeValue_Float("Phase", self, 0 ));
	
	wavetable_apply = function(typ) {
		if(wavetable_selecting == noone) return; 
		attributes.wavetable[wavetable_selecting] = typ;   
		resetDisplayTable(); 
		triggerRender();
	}
	
	wavetable_selecting = noone;
	wavetable_menu = [
		new MenuItem("Sine",     function() /*=>*/ {return wavetable_apply(WAVETABLE_FN.sine)}   , [ s_inspector_wavetable, 0 ]),
		new MenuItem("Square",   function() /*=>*/ {return wavetable_apply(WAVETABLE_FN.square)} , [ s_inspector_wavetable, 1 ]),
		new MenuItem("Triangle", function() /*=>*/ {return wavetable_apply(WAVETABLE_FN.tri)}    , [ s_inspector_wavetable, 3 ]),
		new MenuItem("Sawtooth", function() /*=>*/ {return wavetable_apply(WAVETABLE_FN.saw)}    , [ s_inspector_wavetable, 2 ]),
	];
	
	wavetable_editor = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus, _panel = noone) {
		var _h = ui(160);
		var pd = ui(8);
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _h, COLORS.node_composite_bg_blend, 1);
		
		if(array_empty(wavetable_display_data)) return _h;
		
		var xr   = graph_res;
		var yr   = attributes.wavetable_y_res;
		var _len = array_length(attributes.wavetable);
		
		var x0 = _x + pd;
		var x1 = _x + _w - pd;
		var ww = _w - pd * 2;
		
		var y0 = _y + pd;
		var y1 = _y + _h - pd;
		var hh = _h - pd * 2;
		
		var _gra_w = ww * .6;
		var _gra_h = ui(32);
		
		var _gra_p = _gra_w / (xr - 1);
		var _gra_l = (hh - _gra_h) / yr;
		
		var ys = y1 - _gra_h / 2;
		var ox, oy, nx, ny;
		
		draw_set_color(COLORS._main_icon_light);
		draw_set_alpha(.2);
		
		for( var i = 0; i < yr; i++ ) {
			var _crv   = wavetable_display_data[i];
			var _gra_y = ys - _gra_l * i;
			var _gra_x = lerp(x0, x1 - _gra_w, i / yr);
			
			for( var j = 0; j < xr; j++ ) {
				var _val = _crv[j];
				nx = _gra_x + j    * _gra_p;
				ny = _gra_y - _val * _gra_h / 2;
				
				if(j) draw_line(ox, oy, nx, ny);
				
				ox = nx;
				oy = ny;
			}
		}
		
		draw_set_color(COLORS._main_icon_light);
		draw_set_alpha(.5);
		
		for( var i = 0; i < array_length(wavetable_display_data_step); i++ ) {
			var _ind   = safe_mod(i, _len) / _len * yr;
			var _crv   = wavetable_display_data_step[i];
			var _gra_y = ys - _gra_l * _ind;
			var _gra_x = lerp(x0, x1 - _gra_w, _ind / yr);
			
			for( var j = 0; j < xr; j++ ) {
				var _val = _crv[j];
				nx = _gra_x + j    * _gra_p;
				ny = _gra_y - _val * _gra_h / 2;
				
				if(j) draw_line(ox, oy, nx, ny);
				
				ox = nx;
				oy = ny;
			}
		}
		
		draw_set_color(COLORS._main_accent);
		draw_set_alpha(1);
		
		var _ind = safe_mod(abs(pattern), _len) / _len * yr;
		
		var _crv   = wavetable_display_curent;
		var _gra_y = ys - _gra_l * _ind;
		var _gra_x = lerp(x0, x1 - _gra_w, _ind / yr);
		
		for( var j = 0; j < xr; j++ ) {
			var _val = _crv[j];
			nx = _gra_x + j    * _gra_p;
			ny = _gra_y - _val * _gra_h / 2;
			
			if(j) draw_line_width(ox, oy, nx, ny, 2);
			
			ox = nx;
			oy = ny;
		}
		
		var _yy = _y + _h + ui(4);
		var _tw = ui(28);
		var _th = ui(24);
		_h += ui(4) + _th + ui(8);
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _yy, _w, _th + ui(8), COLORS.node_composite_bg_blend, 1);
		
		var _del = noone;
		
		for( var i = 0; i <= _len; i++ ) {
			var _tx = _x  + ui(4) + i * (_tw + ui(4));
			var _ty = _yy + ui(4);
			
			if(_hover && point_in_rectangle(_m[0], _m[1], _tx, _ty, _tx + _tw, _ty + _th)) {
				
				if(i == _len) {
					if(mouse_press(mb_left, _focus)) {
						array_push(attributes.wavetable, 0);
						wavetable_selecting = i;
						menuCall("", wavetable_menu);
					}
					
				} else {
					draw_sprite_stretched_ext(THEME.button_def, 1, _tx, _ty, _tw, _th, COLORS._main_icon_light, 1);
					
					if(mouse_press(mb_left, _focus)) {
						wavetable_selecting = i;
						menuCall("", wavetable_menu);
					}
					
					if(_len > 1 && mouse_press(mb_right, _focus)) 
						_del = i;
				}
			}
				
			if(i < _len) {
				var _type = attributes.wavetable[i];
				
				draw_sprite_stretched_ext(THEME.button_def, 0, _tx, _ty, _tw, _th, COLORS._main_icon_light, .5);
				draw_sprite_ui(s_inspector_wavetable, _type, _tx + _tw / 2, _ty + _th / 2, 1, 1, 0, COLORS._main_icon_light, 1);
				
			} else
				draw_sprite_ui(THEME.add_16, _type, _tx + _tw / 2, _ty + _th / 2, 1, 1, 0, COLORS._main_value_positive, 1);
			
		}
		
		if(_del != noone) {
			array_delete(attributes.wavetable, _del, 1);
			resetDisplayTable();
			triggerRender();
		}
		
		return _h;
	});
	
	array_append(input_display_list, [
		["Wave",	false], wavetable_editor, inl + 0, inl + 1, inl + 2, inl + 3,  
	]);
	
	attributes.wavetable = [
		WAVETABLE_FN.sine,
		WAVETABLE_FN.square,
		WAVETABLE_FN.tri,
	];
	
	attributes.wavetable_y_res  = 24;
	wavetable_display_data      = [];
	wavetable_display_data_step = [];
	wavetable_display_curent    = [];
	
	pattern   = 0;
	frequency = 0;
	phase     = 0;
	
	range_min = 0;
	range_max = 0;
	
	function getPattern(_patt, _x) {
		var _len = array_length(attributes.wavetable);
		var _ind = safe_mod(_patt, _len);
		if(_ind < 0) _ind = abs(_ind);
		
		switch(attributes.wavetable[_ind]) {
			case WAVETABLE_FN.sine   : return sin(_x * pi * 2);
			case WAVETABLE_FN.square : return (1 - floor(frac(_x) * 2))   * 2 - 1;
			case WAVETABLE_FN.tri    : return abs(frac(_x + .5) - .5) * 2 * 2 - 1;
			case WAVETABLE_FN.saw    : return frac(_x + 0.5)              * 2 - 1;
		}
		
		return 0;
	}
	
	function resetDisplayTable() {
		var xr   = graph_res;
		var yr   = attributes.wavetable_y_res;
		var _len = array_length(attributes.wavetable);
		var xri  = 1 / xr;
		var yri  = 1 / (yr - 1);
		
		wavetable_display_data = array_verify(wavetable_display_data, yr);
		for( var i = 0; i < yr; i++ ) {
			var _patt = i * yri * _len;
			wavetable_display_data[i] = array_verify(wavetable_display_data[i], xr);
			
			for( var j = 0; j < xr; j++ )
				wavetable_display_data[i][j] = __evalRaw(_patt, (j * xri) * 2);
		}
		
		wavetable_display_data_step = array_verify(wavetable_display_data_step, _len);
		for( var i = 0; i < _len; i++ ) {
			wavetable_display_data_step[i] = array_verify(wavetable_display_data_step[i], xr);
			
			for( var j = 0; j < xr; j++ )
				wavetable_display_data_step[i][j] = __evalRaw(i, (j * xri) * 2);
		}
		
	} resetDisplayTable();
	
	static __evalRaw = function(_patt, _x = 0) {
		_patt = abs(_patt);
		
		var _p0 = floor(_patt);
		var _p1 = floor(_patt) + 1;
		var _fr = frac(_patt);
		
		var _v0 = getPattern(_p0, _x);
		var _v1 = getPattern(_p1, _x);
		var _lr = lerp(_v0, _v1, _fr);
		
		return _lr;
	}
	
	static __fnEval = function(_x = 0) {
		_x = _x * frequency - phase;
		
		var _lr = __evalRaw(pattern, _x) * .5 + .5;
		return lerp(range_min, range_max, _lr);
	}
	
	static processData = function(_output, _data, _array_index = 0) {
		pattern     = _data[inl + 0];
		var ran     = _data[inl + 1];
		range_min   = array_safe_get_fast(ran, 0);
		range_max   = array_safe_get_fast(ran, 1);
		
		frequency   = _data[inl + 2];
		phase       = _data[inl + 3];
		
		var val = __fnEval(CURRENT_FRAME / TOTAL_FRAMES);
		text_display = val;
		
		wavetable_display_curent = array_verify(wavetable_display_curent, graph_res);
		for( var j = 0; j < graph_res; j++ )
			wavetable_display_curent[j] = __evalRaw(pattern, (j / graph_res) * 2);
		
		return val;
	}
	
	static postApplyDeserialize  = function() {
		resetDisplayTable();
	}
}