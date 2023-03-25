enum TEXT_AREA_FORMAT {
	_default,
	code,
	delimiter
}

function textArea(_input, _onModify, _extras = noone) : textInput(_input, _onModify, _extras) constructor {
	font   = f_p0;
	hide   = false;
	line_width = 1000;
	
	auto_update = false;
	
	_input_text_line = [];
	_current_text = "";
	_input_text = "";
	_prev_text = "";
	_last_value = "";
	_prev_width = 0;
	
	min_lines = 0;
	
	cursor			= 0;
	
	cursor_pos_x	= 0;
	cursor_pos_x_to	= 0;
	cursor_pos_y	= 0;
	cursor_pos_y_to	= 0;
	cursor_line = 0;
	
	cursor_select	= -1;
	
	click_block = 0;
	format = TEXT_AREA_FORMAT._default;
	
	code_line_width = 48;
	
	_cl = -1;
	
	static activate = function() { 
		WIDGET_CURRENT = self;
		WIDGET_CURRENT_SCROLL = parent;
		parentFocus();
		
		_input_text		= _current_text;
		_last_value     = _current_text;
		
		cursor_pos_x = 0;
		cursor_pos_y = 0;
		click_block = 1;
		KEYBOARD_STRING = "";
		keyboard_lastkey = -1;
					
		cut_line();
	}
	
	static deactivate = function() { 
		if(WIDGET_CURRENT != self) return;
		apply();
		WIDGET_CURRENT = noone;
		UNDO_HOLDING = false;
	}
	
	static apply = function() {
		if(onModify) onModify(_input_text);
		UNDO_HOLDING = true;
	}
	
	static move_cursor = function(delta) {
		var ll = string_length(_input_text);
		cursor = clamp(cursor + delta, 0, ll);
	}
	
	static cut_line = function() {
		_input_text_line = [];
		draw_set_font(font);
		
		var _txtLines = string_splice(_input_text, "\n");
		var ss = "";
		
		for( var i = 0; i < array_length(_txtLines); i++ ) {
			var _txt = _txtLines[i] + (i < array_length(_txtLines)? "\n" : "");
			var words = string_splice(_txt, " ");
			var currW = 0;
			var currL = "";
			var cut = true;
			
			for( var j = 0; j < array_length(words); j++ ) {
				var word = words[j];
				if(j) word = " " + word;
				
				if(string_width(word) > line_width) { //the entire word is longer than a line
					for( var k = 1; k <= string_length(word); k++ ) {
						var ch = string_char_at(word, k);
						
						if(currW + string_width(ch) > line_width) {
							array_push(_input_text_line, currL);
							currW = 0;
							currL = "";
						}
						
						currL += ch;
						currW += string_width(ch);
					}
					continue;
				} 
				
				if(currW + string_width(word) > line_width) {
					array_push(_input_text_line, currL);
					currW = 0;
					currL = "";
				}
				
				cut = true;
				currW += string_width(word);
				currL += word;
			}
			
			if(cut) array_push(_input_text_line, currL);
		}
	}
	
	static editText = function() {
		#region text editor
			if(key_mod_press(CTRL) && keyboard_check_pressed(ord("A"))) {
				cursor_select	= 0;
				cursor			= string_length(_input_text);
			} else if(key_mod_press(CTRL) && (keyboard_check_pressed(ord("C")) || keyboard_check_pressed(ord("X")))) {
				if(cursor_select != -1) {
					var minc = min(cursor, cursor_select);
					var maxc = max(cursor, cursor_select);
					clipboard_set_text(string_copy(_input_text, minc, maxc - minc));
				}
			} else {
				if(key_mod_press(CTRL) && keyboard_check_pressed(ord("V")))
					KEYBOARD_STRING = clipboard_get_text();
					
				if(keyboard_check_pressed(vk_escape)) {
				} else if(keyboard_check_pressed(vk_enter)) {
					if(key_mod_press(SHIFT)) {
						var ch = "\n";
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
					}
				} else if(KEYBOARD_PRESSED == vk_backspace) {
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
				} else if(KEYBOARD_PRESSED == vk_delete || (keyboard_check_pressed(ord("X")) && key_mod_press(CTRL) && cursor_select != -1)) {
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
				} else if(KEYBOARD_STRING != "") {
					var ch			= KEYBOARD_STRING;
					
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
			
			KEYBOARD_STRING = "";
			keyboard_lastkey = -1;
		#endregion
		
		if(auto_update && keyboard_check_pressed(vk_anykey))
			apply();
			
		if(keyboard_check_pressed(vk_home)) {
			if(key_mod_press(SHIFT)) {
				if(cursor_select == -1)
					cursor_select = cursor;
			} else 
				cursor_select	= -1;
			
			if(cursor_line == 0) 
				move_cursor(-cursor);
			else {
				var _str = _input_text_line[cursor_line];
				while(string_char_at(_input_text, cursor) != "\n") {
					if(cursor <= 0) break;
					cursor--;
				}
			}
			
		} else if(keyboard_check_pressed(vk_end)) {
			if(key_mod_press(SHIFT)) {
				if(cursor_select == -1)
					cursor_select = cursor;
			} else 
				cursor_select	= -1;
			
			var _str = _input_text_line[cursor_line];
			while(string_char_at(_input_text, cursor + 1) != "\n" && cursor < string_length(_input_text)) {
				cursor++;
			}
		} else if(keyboard_check_pressed(vk_escape)) {
			_input_text = _last_value;
			cut_line();
			deactivate();
		} else if(keyboard_check_pressed(vk_enter) && !key_mod_press(SHIFT)) {
			deactivate();
		}
	}
	
	static display_text = function(_x, _y, _text, _w, _mx = -1, _my = -1) {
		_text = string_real(_text);
		if(_w != _prev_width) {
			_prev_width = _w;
			cut_line();
		}
		
		var _xx = _x, _ch, _chw;
		var target = -999;
		
		draw_set_text(font, fa_left, fa_top, COLORS._main_text);
		draw_set_alpha(0.5 + 0.5 * interactable)
		
		var ch_x = _x;
		var ch_y = _y;
		var _str;
		
		if(_input_text != _text) {
			_input_text = _text;
			cut_line();
		}
		
		for( var i = 0; i < array_length(_input_text_line); i++ ) {
			_str = _input_text_line[i];
			
			if(format == TEXT_AREA_FORMAT._default)
				draw_text(ch_x, ch_y, _str);
			else if(format == TEXT_AREA_FORMAT.code)
				draw_code(ch_x, ch_y, _str);
			else if(format == TEXT_AREA_FORMAT.delimiter)
				draw_text_delimiter(ch_x, ch_y, _str);
			
			ch_y += line_height();
		}
		
		draw_set_alpha(1);
		
		if(_mx != -1 && _my != -1) {
			var char_run = 0, _l, _ch_w, _ch_h, _str, _chr;
			var sx = _x;
			var ch_x = sx;
			var ch_cxo = sx;
			var ch_cxn = sx;
			var ch_y = _y;
					
			for( var i = 0; i < array_length(_input_text_line); i++ ) {
				_str = string_trim_end(_input_text_line[i]);
				_l = string_length(_str);
				_ch_h = line_height();
				ch_cxo = sx;
				ch_x = sx;
				
				if(ch_y <= _my && ch_y + _ch_h >= _my) {
					target = char_run + _l;
					
					for( var j = 0; j < string_length(_str); j++ ) {
						_chr = string_char_at(_str, j + 1);
						_ch_w = string_width(_chr);
						ch_cxn = ch_x + _ch_w / 2;
						
						if(ch_cxo <= _mx && _mx <= ch_cxn) {
							target = char_run + j;
							break;
						}
						
						ch_x += _ch_w;
						ch_cxo = ch_cxn;
					}
					break;
				}
				char_run += string_length(_input_text_line[i]);	
				ch_y += _ch_h;
			}
		}
		
		if(target != -999) {
			if(mouse_press(mb_left, active) || click_block == 1) {
				cursor_select = -1;
				cursor = target;
				click_block = 0;
			} else if(mouse_click(mb_left, active) && cursor != target) {
				cursor_select = target;
			}
		}
	}
	
	static draw = function(_x, _y, _w, _h, _text, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		_text = string_real(_text);
		_current_text = _text;
		
		//if(format == TEXT_AREA_FORMAT.code) {
		//	print("=== TEXT BOX ===");
		//	print(_text);
		//	print(_current_text);
		//}
		
		if(extras && instanceof(extras) == "buttonClass") {
			extras.setActiveFocus(hover, active);
			extras.draw(_x + _w - ui(32), _y + _h / 2 - ui(32 / 2), ui(32), ui(32), _m, THEME.button_hide);
			_w -= ui(40);
		}
		
		var tx = _x + ui(8);
		var hh = _h;
		
		if(format == TEXT_AREA_FORMAT._default) {
			line_width = _w - ui(16);
		} else if(format == TEXT_AREA_FORMAT.code) {
			line_width = _w - ui(16 + code_line_width);
			tx += ui(code_line_width);
		}
		
		draw_set_font(font);
		var c_h = line_height();
		var line_count = max(min_lines, array_length(_input_text_line));
		hh = max(_h, ui(14) + c_h * line_count);
		
		draw_sprite_stretched(THEME.textbox, 3, _x, _y, _w, hh);
		
		if(format == TEXT_AREA_FORMAT.code) {
			draw_sprite_stretched(THEME.textbox_code, 0, _x, _y, ui(code_line_width), hh);
			draw_set_text(f_p1, fa_right, fa_top, COLORS._main_text_sub);
			
			var lx = _x + ui(code_line_width - 8);
			for( var i = 0; i < line_count; i++ ) {
				var ly = _y + ui(7) + i * c_h;
				
				draw_text(lx, ly, string(i + 1));
			}
		}
		
		if(self == WIDGET_CURRENT) { 
			draw_set_text(font, fa_left, fa_top, COLORS._main_text);
			draw_sprite_stretched(THEME.textbox, 2, _x, _y, _w, hh);
			editText();
			
			#region cursor
				if(KEYBOARD_PRESSED == vk_left) {
					if(key_mod_press(SHIFT)) {
						if(cursor_select == -1)
							cursor_select = cursor;
					} else 
						cursor_select	= -1;
						
					move_cursor(-1);
					if(key_mod_press(CTRL)) {
						while(cursor > 0) {
							var ch = string_char_at(_input_text, cursor);
							if(ch == " " || ch == "\n") break;
							cursor--;
						}
					} 
				}
				if(KEYBOARD_PRESSED == vk_right) {
					if(key_mod_press(SHIFT)) {
						if(cursor_select == -1)
							cursor_select = cursor;
					} else 
						cursor_select	= -1;
					
					move_cursor(1);
					if(key_mod_press(CTRL)) {
						while(cursor < string_length(_input_text)) {
							var ch = string_char_at(_input_text, cursor);
							if(ch == " " || ch == "\n") break;
							cursor++;
						}
					} 
				}
				
				if(KEYBOARD_PRESSED == vk_up) {
					var _target;
					
					if(cursor_line == 0) 
						_target = 0;
					else {
						var _l = cursor_line - 1;
						var _str = _input_text_line[_l];
						var _run = tx;
						var _char = 0;
						
						for( var i = 0; i < _l; i++ ) {
							_char += string_length(_input_text_line[i]);
						}
						
						for( var i = 1; i <= string_length(_str); i++ ) {
							var _chr = string_char_at(_str, i);
							_run += string_width(_chr);
							if(_run > cursor_pos_x_to)
								break;
							_char++;
						}
						
						_target = _char;
					}
					
					if(key_mod_press(SHIFT)) {
						if(cursor_select == -1)
							cursor_select = cursor;
					} else 
						cursor_select	= -1;
					
					cursor = _target;
				}
				
				if(KEYBOARD_PRESSED == vk_down) {
					var _target;
					
					if(cursor_line == array_length(_input_text_line) - 1) 
						_target = string_length(_input_text);
					else {
						var _l = cursor_line + 1;
						var _str = _input_text_line[_l];
						var _run = tx;
						var _char = 0;
						
						for( var i = 0; i < _l; i++ ) {
							_char += string_length(_input_text_line[i]);
						}
						
						for( var i = 1; i <= string_length(_str); i++ ) {
							var _chr = string_char_at(_str, i);
							_run += string_width(_chr);
							if(_run > cursor_pos_x_to) break;
							_char++;
						}
						
						_target = _char;
					}
					
					if(key_mod_press(SHIFT)) {
						if(cursor_select == -1)
							cursor_select = cursor;
					} else 
						cursor_select	= -1;
					
					cursor = _target;
				}
			#endregion
			
			#region draw
				draw_set_text(font, fa_left, fa_top, COLORS._main_text);
				
				#region draw cursor highlight
					var char_run = 0, _l, _str;
					var ch_x = tx;
					var ch_y = _y + ui(7);
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
							draw_set_color(COLORS.widget_text_highlight);
							
							if(char_run <= ch_sel_min && char_run + _l > ch_sel_min) {
								var x1 = tx + string_width(string_copy(_str, 1, ch_sel_min - char_run));
								var x2 = tx + string_width(string_copy(_str, 1, ch_sel_max - char_run));
						
								draw_roundrect_ext(x1, ch_y, x2, ch_y + c_h, ui(8), ui(8), 0);
							} else if(char_run >= ch_sel_min && char_run + _l < ch_sel_max) {
								var x2 = tx + string_width(_str);
								
								draw_roundrect_ext(tx, ch_y, x2, ch_y + c_h, ui(8), ui(8), 0);
							} else if(char_run > ch_sel_min && char_run <= ch_sel_max && char_run + _l >= ch_sel_max) {
								var x2 = tx + string_width(string_copy(_str, 1, ch_sel_max - char_run));
								
								draw_roundrect_ext(tx, ch_y, x2, ch_y + c_h, ui(8), ui(8), 0);
							}
						}
						
						if(char_run <= cursor && cursor <= char_run + _l) {
							if(format == TEXT_AREA_FORMAT.delimiter) {
								var str_cur = string_copy(_str, 1, cursor - char_run);
								str_cur = string_replace_all(str_cur, " ", "<space>");
								cursor_pos_x_to = ch_x + string_width(str_cur);
							} else 
								cursor_pos_x_to = ch_x + string_width(string_copy(_str, 1, cursor - char_run));
							cursor_pos_y_to = ch_y;
							cursor_line = i;
						}
						char_run += _l;
						ch_y += line_height();
					}
					
					cursor_pos_x = cursor_pos_x == 0? cursor_pos_x_to : lerp_float(cursor_pos_x, cursor_pos_x_to, 4);
					cursor_pos_y = cursor_pos_y == 0? cursor_pos_y_to : lerp_float(cursor_pos_y, cursor_pos_y_to, 4);
				#endregion
				
				var _mx = -1;
				var _my = -1;
				if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + hh)) {
					_mx = _m[0];
					_my = _m[1];
				}
				
				display_text(tx, _y + ui(7), _input_text, _w - ui(4), _mx, _my);
				
				if(cursor_pos_y != 0 && cursor_pos_x != 0) {
					draw_set_color(COLORS._main_text_accent);
					draw_line_width(cursor_pos_x, cursor_pos_y, cursor_pos_x, cursor_pos_y + c_h, 2);
				}
			#endregion
			
			if(!point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + hh) && mouse_press(mb_left)) {
				deactivate();
			}
		} else {
			if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + hh)) {
				if(hide)
					draw_sprite_stretched_ext(THEME.textbox, 1, _x, _y, _w, hh, c_white, 0.5);	
				else
					draw_sprite_stretched_ext(THEME.textbox, 1, _x, _y, _w, hh, c_white, 0.5 + 0.5 * interactable);	
				if(mouse_press(mb_left, active))
					activate();
			} else if(!hide) {
				draw_sprite_stretched(THEME.textbox, 0, _x, _y, _w, hh);
			}
			
			display_text(tx, _y + ui(7), _text, _w - ui(4));
		}
		
		resetFocus();
		
		return hh;
	}
}