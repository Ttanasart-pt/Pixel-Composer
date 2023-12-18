enum MKSPARK_DIRR { main, diag }
enum MKSPARK      { dir, y, x, speed, length, lendel, time }

function Node_MK_Sparkle(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Sparkle";
	dimension_index = -1;
	update_on_frame = true;
	
	inputs[| 0] = nodeValue("Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 5);
	
	inputs[| 1] = nodeValue("Sparkle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 
			[ MKSPARK_DIRR.main, 0,  0, 2, 1, 0, 0 ], 
			[ MKSPARK_DIRR.main, 0, -1, 1, 1, 0, 0 ], 
		])
		.setArrayDepth(2)
		.setArrayDynamic();
	
	inputs[| 2] = nodeValue("Start frame", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	inputs[| 3] = nodeValue("Speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 4] = nodeValue("Loop", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [])
		.setArrayDepth(1)
		.setArrayDynamic();
	
	editor_rect       = [ 0, 0 ];
	editor_rect_to    = [ 0, 0 ];
	editor_rect_hover = 0;
	editor_hold_ind   = -1;
	editor_hold_sx    = -1;
	editor_timer      = -1;
	editor_timer_mx   = 0;
	editor_timer_sx   = 0;
	
	sparkleEditor = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { #region
		var _size = inputs[| 0].getValue();
		var _sprk = inputs[| 1].getValue();
		
		var _c = ceil(_size / 2);
		
		var rows = array_create(_c);
		for( var i = 0; i < _c; i++ ) rows[i] = [];
		
		for( var i = 0, n = array_length(_sprk); i < n; i++ ) {
			var _sp = _sprk[i];
			var _rw = _sp[MKSPARK.y];
			
			array_push(rows[_rw], i);
		}
		
		_y += ui(8);
		var cell_s = ui(32);
		var cell_w = (4 + _c) * cell_s;
		var cx0 = _x + _w / 2 - cell_w / 2;
		var cx1 = cx0 + cell_s;
		var cx2 = cx1 + cell_s * 3;
		var cx3 = cx2 + cell_s * _c;
		var cy = _y + ui(24);
		
		var _amo = 0;
		for( var i = 0, n = array_length(rows); i < n; i++ )
			_amo += 1 + array_length(rows[i]);
		
		var _h = ui(8) + _amo * cell_s + ui(48);
		
		//draw_sprite_stretched(s_mk_sparkle_bg, 0, _x, _y, _w, _h);
		draw_set_circle_precision(32);
		
		var _rect_hover = 0;
		var _cont_hover = -1;
		var _arr_ind    = 0;
		var _arr_ins    = -1;
		var _arr_del    = -1;
		var _arr_insrw  = -1;
		var _arr_insx   = -1;
		
		for( var i = 0, n = array_length(rows); i < n; i++ ) {
			var row = rows[i];
			
			for( var j = 0, m = array_length(row); j <= m; j++ ) {
				var _cy = cy + cell_s / 2;
				
				var _chov = 0;
				var _tx = cx0 + cell_s / 2 - 4;
				var _ty = _cy;
				if(j < m) {
					draw_set_color(#272736);
					draw_circle(_tx, _ty, cell_s / 2 - 4, false);
				}
				
				if(_hover && point_in_rectangle(_m[0], _m[1], _tx - cell_s / 2, _ty - cell_s / 2, _tx + cell_s / 2, _ty + cell_s / 2)) {
					editor_rect_to = [ _tx + ui(1), _ty ];
					_rect_hover = 1;
					_chov       = 2;
				}
					
				var _cx   = cx1;
				var _chox = 0;
				
				for( var k = -3; k < _c; k++ ) {
					var cc = abs(i + (k >= 0? k : k - 1)) % 2? #272736 : #313143;
					draw_set_color(k >= 0? cc : merge_color(cc, #171723, 0.5));
					draw_rectangle(_cx, cy, _cx + cell_s, cy + cell_s, false);
					
					if(_hover && point_in_rectangle(_m[0], _m[1], _cx, cy, _cx + cell_s - 1, cy + cell_s - 1)) {
						editor_rect_to = [_cx + cell_s / 2, cy + cell_s / 2];
						_rect_hover = 1;
						_cont_hover = _arr_ind;
						_chov       = 1;
						_chox       = k;
						_arr_insx   = k;
					}
					
					_cx += cell_s;
				}
				
				if(mouse_press(mb_left, _chov == 1 && _focus)) {
					editor_hold_sx  = _chox;
					editor_hold_ind = _cont_hover;
				}
				
				if(j == m) {
					if(mouse_press(mb_left, _chov == 1 && _focus)) {
						_arr_ins   = _cont_hover;
						_arr_insrw = i;
					}
					
					cy += cell_s;
					break;
				}
				
				var _dx = cx3 + cell_s / 2 + 4;
				draw_set_color(merge_color(#1e1e2c, c_red, 0.2));
				draw_circle(_dx, _ty, ui(6), false);
				
				if(_hover && point_in_circle(_m[0], _m[1], _dx, _ty, ui(12))) {
					draw_set_color(merge_color(#1e1e2c, c_red, 0.5));
					draw_circle(_dx, _ty, ui(6), false);
					
					if(mouse_press(mb_left, _focus)) 
						_arr_del = _arr_ind;
				}
				
				_arr_ind++;
				var _id  = row[j];
				var _sp  = _sprk[_id];
				var _dr  = _sp[MKSPARK.dir];
				var _xs  = _sp[MKSPARK.x];
				var _spd = _sp[MKSPARK.speed];
				var _dr  = _sp[MKSPARK.length];
				var _bl  = _sp[MKSPARK.lendel];
				var _tm  = _sp[MKSPARK.time];
				
				if(mouse_press(mb_left, _focus))  {
					if(_chov == 2) {
						editor_timer      = _id;
						editor_timer_mx   = _m[0];
						editor_timer_sx   = _tm;
					}
				}
				
				var _lx0 = cx1 + cell_s * (3 + _xs) + ui(6);
				var _lx1 = _lx0 + _spd * cell_s;
				
				draw_set_color(c_white);
				draw_line_width(_lx0, _cy, _lx1, _cy, 4);
				
				     if(_tm < 0) draw_set_color(COLORS._main_value_negative);
				else if(_tm > 0) draw_set_color(COLORS._main_value_positive);
				else             draw_set_color(c_white);
				
				draw_line_width(_tx, _ty, _tx + lengthdir_x(cell_s / 2 - 6, 90 - _tm * 90), 
				                          _ty + lengthdir_y(cell_s / 2 - 6, 90 - _tm * 90), 4);
				
				cy += cell_s;
			}
		}
		
		if(_arr_ins > -1)
			array_insert(_sprk, _arr_ins, [ MKSPARK_DIRR.main, _arr_insrw, _arr_insx, 1, 1, 0, 0 ]);
		
		if(_arr_del > -1)
			array_delete(_sprk, _arr_del, 1);
		
		if(editor_hold_ind > -1) {
			_sprk[editor_hold_ind][2] = editor_hold_sx;
			_sprk[editor_hold_ind][3] = _arr_insx - editor_hold_sx + 1;
			
			if(mouse_release(mb_left))
				editor_hold_ind = -1;
		}
		
		if(editor_timer > -1) {
			var _tim = editor_timer_sx + (_m[0] - editor_timer_mx) / 32;
			_sprk[editor_timer][6] = clamp(round(_tim), -3, 3);
			
			if(mouse_release(mb_left))
				editor_timer = -1;
		}
		
		editor_rect_hover = lerp_float(editor_rect_hover, _rect_hover, 4);
		if(editor_rect_hover > 0) {
			editor_rect[0] = lerp_float(editor_rect[0], editor_rect_to[0], 5);
			editor_rect[1] = lerp_float(editor_rect[1], editor_rect_to[1], 5);
			
			var _sels = editor_rect_hover * (cell_s / 2 - 4);
			draw_sprite_stretched_ext(s_mk_sparkle_select, 0, editor_rect[0] - _sels, editor_rect[1] - _sels, _sels * 2, _sels * 2, #6d6d84, 1);
		}
		
		return _h;
	}); #endregion
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 
		["Sparkle",  false], 0, 2, 3, 
		sparkleEditor
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	temp_surface = [ noone, noone ];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _size = _data[0];
		var _sprk = _data[1];
		var _frme = _data[2];
		var _spd  = _data[3];
		var _loop = _data[4];
		
		if(array_empty(_sprk)) return _outSurf;
		
		var _c = floor(_size / 2);
		
		_outSurf        = surface_verify(_outSurf,        _size, _size);
		temp_surface[0] = surface_verify(temp_surface[0], _size, _size);
		temp_surface[1] = surface_verify(temp_surface[1], _size, _size);
		
		var _s0 = temp_surface[0];
		var _s1 = temp_surface[1];
		var _fr = round((CURRENT_FRAME - _frme + 1) * _spd);
		
		if(!array_empty(_loop)) {
			var _ind = CURRENT_FRAME % array_length(_loop);
			_fr = _loop[_ind];
		}
		
		surface_set_target(_s0);
			DRAW_CLEAR
			
			draw_set_color(c_white);
			
			for( var i = 0, n = array_length(_sprk); i < n; i++ ) {
				var _sk = _sprk[i];
				var dr  = _sk[MKSPARK.dir];
				var sy  = _sk[MKSPARK.y];
				var sx  = _sk[MKSPARK.x];
				var sp  = _sk[MKSPARK.speed];
				var ff  = _sk[MKSPARK.time] + _fr;
				var lng = _sk[MKSPARK.length] + _sk[MKSPARK.lendel] - ff;
				
				if(ff < 0 || lng < 0) continue;

				if(dr == MKSPARK_DIRR.main) {
					var _lx = _c + sx - 1 + sp * ff;
					var _ly = _c + sy;
					
					if(lng == 0) draw_point(_lx, _ly);
					else		 draw_line(_lx, _ly, _lx + lng, _ly);
				} else if(dr == MKSPARK_DIRR.diag) {
					var _l0 = _c - 1 + sp * ff;
					var _l1 = _l0 + lng;
					
					if(lng == 0) draw_point(_l0, _l0);
					else		 draw_line(_l0, _l0, _l1, _l1);
				}
			}
			
			BLEND_NORMAL
		surface_reset_target();
		
		surface_set_target(_s1);
			DRAW_CLEAR
		
			draw_surface_ext(_s0, 0,  0, 1,  1, 0, c_white, 1);
			draw_surface_ext(_s0, 0, _size, 1, -1, 0, c_white, 1);
		surface_reset_target();
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			draw_surface_ext(_s1,     0,     0, 1, 1,   0, c_white, 1);
			draw_surface_ext(_s1,     0, _size, 1, 1,  90, c_white, 1);
			draw_surface_ext(_s1, _size, _size, 1, 1, 180, c_white, 1);
			draw_surface_ext(_s1, _size,     0, 1, 1, 270, c_white, 1);
		surface_reset_target();
		
		return _outSurf;
	} #endregion
}