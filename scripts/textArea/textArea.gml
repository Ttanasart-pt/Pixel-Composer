function textArea(_input, _onModify) constructor {
	active = false;
	hover  = false;
	font   = f_p0;
	hide   = false;
	line_width = 1000;
	
	auto_update = false;
	
	input = _input;
	onModify = _onModify;
	
	_input_text_line = [];
	_input_text = "";
	_prev_text = "";
	_last_value = "";
	
	cursor			= 0;
	
	cursor_pos_x	= 0;
	cursor_pos_x_to	= 0;
	cursor_pos_y	= 0;
	cursor_pos_y_to	= 0;
	cursor_line = 0;
	
	cursor_select	= -1;
	
	click_block = 0;
	
	static apply = function() {
		if(onModify) onModify(_input_text);
	}
	
	static move_cursor = function(delta) {
		var ll = string_length(_input_text);
		cursor = clamp(cursor + delta, 0, ll + 1);
	}
	
	static cut_line = function() {
		_input_text_line = [];
		
		var ch, i = 1, ss = "", _txt = _prev_text;
		var len = string_length(_prev_text);
		
		draw_set_font(font);
		while(string_length(_txt) > 0) {
			var sp = string_pos(" ", _txt);
			if(sp == 0) sp = string_length(_txt);
			
			var _ps = string_copy(_txt, 1, sp);
			_txt = string_copy(_txt, sp + 1, string_length(_txt) - sp);
			
			if(string_width(ss + _ps) >= line_width) {
				array_push(_input_text_line, ss);
				ss = _ps;
			} else if(string_length(_txt) <= 0) {
				array_push(_input_text_line, ss + _ps);
				ss = "";
			} else {
				ss += _ps;	
			}
		}
	}
	
	static editText = function() {
		#region text editor
			if(keyboard_check_released(ord("V")) && keyboard_check(vk_control)) {
				_input_text = clipboard_get_text();
				cut_line();
			}
			
			if(keyboard_check(vk_control)) {
				if(keyboard_check_pressed(ord("A"))) {
					cursor_select	= 0;
					cursor			= string_length(_input_text);
				}
			} else {
				if(keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_enter)) {
				} else if(keyboard_check_pressed(vk_backspace)) {
					if(cursor_select == -1) {
						var str_before	= string_copy(_input_text, 1, cursor - 1);
						var str_after	= string_copy(_input_text, cursor + 1, string_length(_input_text) - cursor);
						
						_input_text		= str_before + str_after;
						cut_line();
					} else {
						var minc = min(cursor, cursor_select);
						var maxc = max(cursor, cursor_select);
						
						var str_before	= string_copy(_input_text, 1, minc);
						var str_after	= string_copy(_input_text, maxc + 1, string_length(_input_text) - maxc);
						
						cursor = minc + 1;
						_input_text	= str_before + str_after;
						cut_line();
					}
					
					cursor_select	= -1;
					move_cursor(-1);
				} else if(keyboard_check_pressed(vk_delete)) {
					if(cursor_select == -1) {
						var str_before	= string_copy(_input_text, 1, cursor);
						var str_after	= string_copy(_input_text, cursor + 2, string_length(_input_text) - cursor - 1);
						
						_input_text		= str_before + str_after;
						cut_line();
					} else {
						var minc = min(cursor, cursor_select);
						var maxc = max(cursor, cursor_select);
						
						var str_before	= string_copy(_input_text, 1, minc);
						var str_after	= string_copy(_input_text, maxc + 1, string_length(_input_text) - maxc);
						
						cursor = minc;
						_input_text		= str_before + str_after;
						cut_line();
					}
					cursor_select	= -1;
				} else if(keyboard_string != "") {
					var ch			= keyboard_string;
					
					if(cursor_select == -1) {
						var str_before	= string_copy(_input_text, 1, cursor);
						var str_after	= string_copy(_input_text, cursor + 1, string_length(_input_text) - cursor);
						
						_input_text		= str_before + ch + str_after;
						cut_line();
						move_cursor(string_length(ch));
					} else {
						var minc = min(cursor, cursor_select);
						var maxc = max(cursor, cursor_select);
						
						var str_before	= string_copy(_input_text, 1, minc);
						var str_after	= string_copy(_input_text, maxc + 1, string_length(_input_text) - maxc);
						
						_input_text		= str_before + ch + str_after;
						cut_line();
						cursor = minc + string_length(ch);
					}
					
					cursor_select	= -1;
				}
			}
			
			keyboard_string = "";
			keyboard_lastkey = -1;
		#endregion
		
		if(auto_update && keyboard_check_pressed(vk_anykey))
			apply();
			
		if(keyboard_check_pressed(vk_escape)) {
			_input_text = _last_value;
			cut_line();
			apply();
			TEXTBOX_ACTIVE = noone;
		} else if(keyboard_check_pressed(vk_enter)) {
			apply();
			TEXTBOX_ACTIVE = noone;
		}
	}
	
	static display_text = function(_x, _y, _text, _w, _mx = -1, _my = -1) {
		var _xx = _x, _ch, _chw;
		var target = -999;
		
		draw_set_text(font, fa_left, fa_top, c_white);
		
		var ch_x = _x;
		var ch_y = _y;
		var _str;
		
		if(_prev_text != _text) {
			_prev_text = _text;
			cut_line();
		}
		
		for( var i = 0; i < array_length(_input_text_line); i++ ) {
			_str = _input_text_line[i];
			draw_text(ch_x, ch_y, _str);
			ch_y += string_height(_str);
		}
		//draw_text_ext(_x, _y, _text, -1, _w - 16);
		
		if(_mx != -1 && _my != -1) {
			var char_run = 0, _l, _ch_w, _ch_h, _str, _chr;
			var ch_x = _x;
			var ch_cxo = _x, ch_cxn = _x;
			var ch_y = _y;
					
			for( var i = 0; i < array_length(_input_text_line); i++ ) {
				_str = _input_text_line[i];
				_l = string_length(_str);
				_ch_h = string_height(_str);
				
				if(ch_y <= _my && ch_y + _ch_h >= _my) {
					for( var j = 0; j < string_length(_str); j++ ) {
						_chr = string_char_at(_str, j + 1);
						_ch_w = string_width(_chr);
						ch_cxn = ch_x + _ch_w / 2;
						
						if(ch_cxo <= _mx && ch_cxn >= _mx) {
							target = char_run + j;
							break;
						}
						
						ch_x += _ch_w;
						ch_cxo = ch_cxn;
					}
					break;
				}
				char_run += _l;	
				ch_y += _ch_h;
			}
		}
		
		if(target != -999) {
			if(mouse_check_button_pressed(mb_left) || click_block == 1) {
				cursor_select = -1;
				cursor = target;
				click_block = 0;
			} else if(mouse_check_button(mb_left) && cursor != target) {
				cursor_select = target;
			}
		}
	}
	
	static draw = function(_x, _y, _w, _h, _text, _m) {
		var tx = _x + 8;
		var hh = _h;
		line_width = _w - 16;
		
		draw_set_font(font);
		var c_h = string_height("l");
		hh = max(_h, 14 + c_h * array_length(_input_text_line));
		
		if(self == TEXTBOX_ACTIVE) { 
			draw_sprite_stretched(s_textbox, 2, _x, _y, _w, hh);
			editText();
			
			#region cursor
				if(keyboard_check_pressed(vk_left)) {
					if(keyboard_check(vk_shift)) {
						if(cursor_select == -1)
							cursor_select = cursor;
					} else 
						cursor_select	= -1;
						
					move_cursor(-1);
				}
				if(keyboard_check_pressed(vk_right)) {
					if(keyboard_check(vk_shift)) {
						if(cursor_select == -1)
							cursor_select = cursor;
					} else 
						cursor_select	= -1;
					
					move_cursor(1);
				}
				
				if(keyboard_check_pressed(vk_up)) {
					if(cursor_line == 0) 
						cursor = 0;
					else {
						var _l = cursor_line - 1;
						var _str = _input_text_line[_l];
						var _run = tx;
						var _char = 0;
						
						for( var i = 0; i < _l - 1; i++ ) {
							_char += string_length(_input_text_line[i]);
						}
						
						for( var i = 0; i < string_length(_str); i++ ) {
							var _chr = string_char_at(_str, i + 1);
							_run += string_width(_chr);
							if(_run > cursor_pos_x_to) {
								_char += i;
								break;
							}
						}
						
						cursor = _char;
					}
				}
				
				if(keyboard_check_pressed(vk_down)) {
					if(cursor_line == array_length(_input_text_line) - 1) 
						cursor = string_length(_prev_text);
					else {
						var _l = cursor_line + 1;
						var _str = _input_text_line[_l];
						var _run = tx;
						var _char = 0;
						
						for( var i = 0; i < _l; i++ ) {
							_char += string_length(_input_text_line[i]);
						}
						
						for( var i = 0; i < string_length(_str); i++ ) {
							var _chr = string_char_at(_str, i + 1);
							_run += string_width(_chr);
							if(_run > cursor_pos_x_to) {
								_char += i;
								break;
							}
						}
						
						cursor = _char;
					}
				}
			#endregion
			
			#region draw
				draw_set_text(font, fa_left, fa_top, c_white);
				
				#region draw cursor highlight
					var char_run = 0, _l, _str;
					var ch_x = tx;
					var ch_y = _y + 7;
					var ch_sel_min = -1;
					var ch_sel_max = -1;
					
					if(cursor_select != -1) {
						ch_sel_min = min(cursor_select, cursor);
						ch_sel_max = max(cursor_select, cursor);
					}
					
					for( var i = 0; i < array_length(_input_text_line); i++ ) {
						_str = _input_text_line[i];
						_l = string_length(_str);
						
						if(cursor_select != -1) {
							draw_set_color(c_ui_blue_grey);
							
							if(char_run <= ch_sel_min && char_run + _l > ch_sel_min) {
								var x1 = tx + string_width(string_copy(_str, 1, ch_sel_min - char_run));
								var x2 = tx + string_width(string_copy(_str, 1, ch_sel_max - char_run));
						
								draw_rectangle(x1, ch_y, x2, ch_y + c_h, 0);
							} else if(char_run >= ch_sel_min && char_run + _l < ch_sel_max) {
								var x2 = tx + string_width(_str);
								
								draw_rectangle(tx, ch_y, x2, ch_y + c_h, 0);
							} else if(char_run > ch_sel_min && char_run <= ch_sel_max && char_run + _l > ch_sel_max) {
								var x2 = tx + string_width(string_copy(_str, 1, ch_sel_max - char_run));
								
								draw_rectangle(tx, ch_y, x2, ch_y + c_h, 0);
							}
						}
						
						if(char_run <= cursor && char_run + _l >= cursor) {
							cursor_pos_x_to = ch_x + string_width(string_copy(_str, 1, cursor - char_run));
							cursor_pos_y_to = ch_y;
							cursor_line = i;
						}
						char_run += _l;	
						ch_y += string_height(_str);
					}
					
					cursor_pos_x = cursor_pos_x == 0? cursor_pos_x_to : lerp_float(cursor_pos_x, cursor_pos_x_to, 3);
					cursor_pos_y = cursor_pos_y == 0? cursor_pos_y_to : lerp_float(cursor_pos_y, cursor_pos_y_to, 3);
				#endregion
				
				var _mx = -1;
				var _my = -1;
				if((mouse_check_button_pressed(mb_left) || mouse_check_button(mb_left)) && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + hh)) {
					_mx = _m[0];
					_my = _m[1];
				}
				
				draw_set_color(c_white);
				display_text(tx, _y + 7, _input_text, _w - 4, _mx, _my);
				draw_set_color(c_ui_orange);
				
				draw_line_width(cursor_pos_x, cursor_pos_y, cursor_pos_x, cursor_pos_y + c_h, 2);
			#endregion
			
			if(!point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + hh) && mouse_check_button_pressed(mb_left)) {
				apply();
				TEXTBOX_ACTIVE = noone;
			}
		} else {
			if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + hh)) {
				if(hide)
					draw_sprite_stretched_ext(s_textbox, 1, _x, _y, _w, hh, c_white, 0.5);	
				else
					draw_sprite_stretched(s_textbox, 1, _x, _y, _w, hh);	
				if(active && mouse_check_button_pressed(mb_left)) {
					TEXTBOX_ACTIVE  = self;
					click_block = 1;
					keyboard_string = "";
					keyboard_lastkey = -1;
					
					_input_text		= _text;
					_last_value     = _text;
					
					cut_line();
				}
			} else if(!hide) {
				draw_sprite_stretched(s_textbox, 0, _x, _y, _w, hh);
			}
			
			display_text(tx, _y + 7, string(_text), _w - 4);
		}
		
		hover  = false;
		active = false;
		
		return hh;
	}
}