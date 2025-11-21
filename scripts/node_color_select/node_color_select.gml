function Node_Color_Select(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Select Color";
	
	newActiveInput(5);
	newInput(6, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput(0, nodeValue_Surface("Surface In"));
	newInput(1, nodeValue_Surface("Mask"));
	newInput(2, nodeValue_Slider("Mix", 1));
	__init_mask_modifier(1, 3); // inputs 3, 4
	
	////- =Hue
	newInput(20, nodeValue_Slider("H Shift",     0, [-1,1,0.01] ));
	newInput( 7, nodeValue_Slider("H Min",       0 ));
	newInput( 8, nodeValue_Slider("H Min Range", 0 ));
	newInput( 9, nodeValue_Slider("H Max",       1 ));
	newInput(10, nodeValue_Slider("H Max Range", 0 ));
	
	////- =Saturation
	newInput(21, nodeValue_Slider("S Shift",     0, [-1,1,0.01] ));
	newInput(12, nodeValue_Slider("S Min",       0 ));
	newInput(13, nodeValue_Slider("S Min Range", 0 ));
	newInput(14, nodeValue_Slider("S Max",       1 ));
	newInput(15, nodeValue_Slider("S Max Range", 0 ));
	
	////- =Value
	newInput(22, nodeValue_Slider("V Shift",     0, [-1,1,0.01] ));
	newInput(16, nodeValue_Slider("V Min",       0 ));
	newInput(17, nodeValue_Slider("V Min Range", 0 ));
	newInput(18, nodeValue_Slider("V Max",       1 ));
	newInput(19, nodeValue_Slider("V Max Range", 0 ));
	
	////- =Output
	newInput(11, nodeValue_Bool("Use Input Alpha", 0 ));
	//23
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	dragging_index = noone;
	
	bar_surface  = noone;
	hue_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		_y += ui(2);
		
		var ww = _w + ui(12);
		var hh = ui(12);
		
		var _Shf  = getSingleValue(20);
		var _Min  = getSingleValue( 7);
		var _MinR = getSingleValue( 8);
		var _Max  = getSingleValue( 9);
		var _MaxR = getSingleValue(10);
		
		bar_surface = surface_verify(bar_surface, ww, hh);
		surface_set_shader(bar_surface);
			draw_sprite_stretched_ext(THEME.box_r2, 0, 0, 0, ww, hh, c_white, 1);
		surface_reset_shader();
		
		shader_set(sh_select_color_hue);
			shader_set_f("hueShift",_Shf);
			shader_set_f("hueMinS", _Min - _MinR);
			shader_set_f("hueMinE", _Min + _MinR);
			shader_set_f("hueMaxS", _Max - _MaxR);
			shader_set_f("hueMaxE", _Max + _MaxR);
			
			draw_surface(bar_surface, 0, _y);
		shader_reset();
		draw_sprite_stretched_add(THEME.box_r2, 1, 0, _y, ww, hh, c_white, 0.3);
		
		var _mval = clamp(_m[0] / ww, 0, 1);
		
		var _MinX = ww * _Min;
		var _hov  = _hover && point_in_rectangle(_m[0], _m[1], _MinX - ui(8), _y - ui(2), _MinX + ui(8), _y + hh + ui(2));
		var _col  = make_color_hsv(frac(_Min + _Shf) * 255, 255, 255);
		draw_sprite_stretched_ext(THEME.box_r2, 0, _MinX - ui(3), _y - ui(2), ui(6), hh + ui(4), _col);
		draw_sprite_stretched_ext(THEME.box_r2, 1, _MinX - ui(3), _y - ui(2), ui(6), hh + ui(4), _hov? COLORS._main_accent : CDEF.main_mdblack);
		
		if(_hov && mouse_lpress(_focus)) dragging_index = 7;
		if(dragging_index == 7) { inputs[7].setValue(_mval); if(mouse_lrelease()) dragging_index = noone; }
		
		var _MaxX = ww * _Max;
		var _hov  = _hover && point_in_rectangle(_m[0], _m[1], _MaxX - ui(8), _y - ui(2), _MaxX + ui(8), _y + hh + ui(2));
		var _col  = make_color_hsv(frac(_Max + _Shf) * 255, 255, 255);
		draw_sprite_stretched_ext(THEME.box_r2, 0, _MaxX - ui(3), _y - ui(2), ui(6), hh + ui(4), _col);
		draw_sprite_stretched_ext(THEME.box_r2, 1, _MaxX - ui(3), _y - ui(2), ui(6), hh + ui(4), _hov? COLORS._main_accent : CDEF.main_mdblack);
		
		if(_hov && mouse_lpress(_focus)) dragging_index = 9;
		if(dragging_index == 9) { inputs[9].setValue(_mval); if(mouse_lrelease()) dragging_index = noone; }
		
		return hh + ui(4);
	});
	
	sat_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		_y += ui(2);
		
		var ww = _w + ui(12);
		var hh = ui(12);
		
		var _Min  = getSingleValue(12);
		var _MinR = getSingleValue(13);
		var _Max  = getSingleValue(14);
		var _MaxR = getSingleValue(15);
		
		bar_surface = surface_verify(bar_surface, ww, hh);
		surface_set_shader(bar_surface);
			draw_sprite_stretched_ext(THEME.box_r2, 0, 0, 0, ww, hh, c_white, 1);
		surface_reset_shader();
		
		shader_set(sh_select_color_sat);
			shader_set_f("satMinS", _Min - _MinR);
			shader_set_f("satMinE", _Min + _MinR);
			shader_set_f("satMaxS", _Max - _MaxR);
			shader_set_f("satMaxE", _Max + _MaxR);
			
			draw_surface(bar_surface, 0, _y);
		shader_reset();
		draw_sprite_stretched_add(THEME.box_r2, 1, 0, _y, ww, hh, c_white, 0.3);
		
		var _mval = clamp(_m[0] / ww, 0, 1);
		
		var _MinX = ww * _Min;
		var _hov  = _hover && point_in_rectangle(_m[0], _m[1], _MinX - ui(8), _y - ui(2), _MinX + ui(8), _y + hh + ui(2));
		var _col  = make_color_hsv(255, _Min * 255, 255);
		draw_sprite_stretched_ext(THEME.box_r2, 0, _MinX - ui(3), _y - ui(2), ui(6), hh + ui(4), _col);
		draw_sprite_stretched_ext(THEME.box_r2, 1, _MinX - ui(3), _y - ui(2), ui(6), hh + ui(4), _hov? COLORS._main_accent : CDEF.main_mdblack);
		
		if(_hov && mouse_lpress(_focus)) dragging_index = 12;
		if(dragging_index == 12) { inputs[12].setValue(_mval); if(mouse_lrelease()) dragging_index = noone; }
		
		var _MaxX = ww * _Max;
		var _hov  = _hover && point_in_rectangle(_m[0], _m[1], _MaxX - ui(8), _y - ui(2), _MaxX + ui(8), _y + hh + ui(2));
		var _col  = make_color_hsv(255, _Max * 255, 255);
		draw_sprite_stretched_ext(THEME.box_r2, 0, _MaxX - ui(3), _y - ui(2), ui(6), hh + ui(4), _col);
		draw_sprite_stretched_ext(THEME.box_r2, 1, _MaxX - ui(3), _y - ui(2), ui(6), hh + ui(4), _hov? COLORS._main_accent : CDEF.main_mdblack);
		
		if(_hov && mouse_lpress(_focus)) dragging_index = 14;
		if(dragging_index == 14) { inputs[14].setValue(_mval); if(mouse_lrelease()) dragging_index = noone; }
		
		return hh + ui(4);
	});
	
	val_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		_y += ui(2);
		
		var ww = _w + ui(12);
		var hh = ui(12);
		
		var _Min  = getSingleValue(16);
		var _MinR = getSingleValue(17);
		var _Max  = getSingleValue(18);
		var _MaxR = getSingleValue(19);
		
		bar_surface = surface_verify(bar_surface, ww, hh);
		surface_set_shader(bar_surface);
			draw_sprite_stretched_ext(THEME.box_r2, 0, 0, 0, ww, hh, c_white, 1);
		surface_reset_shader();
		
		shader_set(sh_select_color_val);
			shader_set_f("valMinS", _Min - _MinR);
			shader_set_f("valMinE", _Min + _MinR);
			shader_set_f("valMaxS", _Max - _MaxR);
			shader_set_f("valMaxE", _Max + _MaxR);
			
			draw_surface(bar_surface, 0, _y);
		shader_reset();
		draw_sprite_stretched_add(THEME.box_r2, 1, 0, _y, ww, hh, c_white, 0.3);
		
		var _mval = clamp(_m[0] / ww, 0, 1);
		
		var _MinX = ww * _Min;
		var _hov  = _hover && point_in_rectangle(_m[0], _m[1], _MinX - ui(8), _y - ui(2), _MinX + ui(8), _y + hh + ui(2));
		var _col  = make_color_hsv(255, 0, _Min * 255);
		draw_sprite_stretched_ext(THEME.box_r2, 0, _MinX - ui(3), _y - ui(2), ui(6), hh + ui(4), _col);
		draw_sprite_stretched_ext(THEME.box_r2, 1, _MinX - ui(3), _y - ui(2), ui(6), hh + ui(4), _hov? COLORS._main_accent : CDEF.main_mdblack);
		
		if(_hov && mouse_lpress(_focus)) dragging_index = 16;
		if(dragging_index == 16) { inputs[16].setValue(_mval); if(mouse_lrelease()) dragging_index = noone; }
		
		var _MaxX = ww * _Max;
		var _hov  = _hover && point_in_rectangle(_m[0], _m[1], _MaxX - ui(8), _y - ui(2), _MaxX + ui(8), _y + hh + ui(2));
		var _col  = make_color_hsv(255, 0, _Max * 255);
		draw_sprite_stretched_ext(THEME.box_r2, 0, _MaxX - ui(3), _y - ui(2), ui(6), hh + ui(4), _col);
		draw_sprite_stretched_ext(THEME.box_r2, 1, _MaxX - ui(3), _y - ui(2), ui(6), hh + ui(4), _hov? COLORS._main_accent : CDEF.main_mdblack);
		
		if(_hov && mouse_lpress(_focus)) dragging_index = 18;
		if(dragging_index == 18) { inputs[18].setValue(_mval); if(mouse_lrelease()) dragging_index = noone; }
		
		return hh + ui(4);
	});
	
	input_display_list = [ 5, 6, 
		[ "Surfaces",    true ], 0, 1, 2, 3, 4, 
		[ "Hue",        false ], hue_renderer, 20, 7, 8, 9, 10, 
		[ "Saturation", false ], sat_renderer, 12, 13, 14, 15, 
		[ "Value",      false ], val_renderer, 16, 17, 18, 19, 
		[ "Output",     false ], 11, 
	];
	
	attribute_surface_depth();
	
	////- Nodes
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _surf = _data[0];
			
			var _hShf  = _data[20];
			var _hMin  = _data[ 7];
			var _hMinR = _data[ 8];
			var _hMax  = _data[ 9];
			var _hMaxR = _data[10];
			
			var _sShf  = _data[21];
			var _sMin  = _data[12];
			var _sMinR = _data[13];
			var _sMax  = _data[14];
			var _sMaxR = _data[15];
			
			var _vShf  = _data[22];
			var _vMin  = _data[16];
			var _vMinR = _data[17];
			var _vMax  = _data[18];
			var _vMaxR = _data[19];
			
			var _alpha = _data[11];
		#endregion
		
		surface_set_shader(_outSurf, sh_select_color);
			shader_set_f("hueShift",_hShf);
			shader_set_f("hueMinS", _hMin - _hMinR);
			shader_set_f("hueMinE", _hMin + _hMinR);
			shader_set_f("hueMaxS", _hMax - _hMaxR);
			shader_set_f("hueMaxE", _hMax + _hMaxR);
			
			shader_set_f("satShift",_sShf);
			shader_set_f("satMinS", _sMin - _sMinR);
			shader_set_f("satMinE", _sMin + _sMinR);
			shader_set_f("satMaxS", _sMax - _sMaxR);
			shader_set_f("satMaxE", _sMax + _sMaxR);
			
			shader_set_f("valShift",_vShf);
			shader_set_f("valMinS", _vMin - _vMinR);
			shader_set_f("valMinE", _vMin + _vMinR);
			shader_set_f("valMaxS", _vMax - _vMaxR);
			shader_set_f("valMaxE", _vMax + _vMaxR);
			
			shader_set_i("alpha", _alpha);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[1], _data[2]);
		_outSurf = channel_apply(_surf, _outSurf, _data[6]);
		
		return _outSurf; 
	}
}