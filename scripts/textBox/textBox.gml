enum TEXTBOX_INPUT {
	text,
	number,
	float
}

function textBox(_input, _onModify, _extras = noone) constructor {
	active = false;
	hover  = false;
	align  = fa_right;
	hide   = false;
	font   = noone;
	color  = COLORS._main_text;
	
	no_empty    = true;
	auto_update = false;
	
	slidable = false;
	sliding  = false;
	slide_mx = 0;
	slide_my = 0;
	slide_speed = 1 / 16;
	
	starting_char = 1;
	
	input = _input;
	onModify = _onModify;
	extras = _extras;
	
	_input_text = "";
	_last_text = "";
	
	cursor			= 0;
	cursor_pos		= 0;
	cursor_pos_to	= 0;
	cursor_select	= -1;
	
	disp_x		= 0;
	disp_x_to	= 0;
	disp_x_min	= 0;
	disp_x_max	= 0;
	
	click_block = 0;
	
	sprite_index = -1;
	
	text_surface = surface_create(1, 1);
	
	static apply = function() {
		var _input_text_current = _input_text;
		
		switch(input) {
			case TEXTBOX_INPUT.number	: 				
				_input_text_current = evaluateFunction(_input_text);
				_input_text_current = _input_text_current == ""? 0 : round(_input_text_current);
				break;
			case TEXTBOX_INPUT.float	: 
				_input_text_current = evaluateFunction(_input_text);
				break;
		}
		
		if(no_empty && _input_text_current == "") 
			_input_text_current = _last_text;
		if(onModify) 
			onModify(_input_text_current);
			
		disp_x_to = 0;
	}
	
	static move_cursor = function(delta) {
		var ll = string_length(_input_text) + 1;
		cursor = safe_mod(cursor + delta + ll, ll);
	}
	
	static getDisplayText = function(val) {
		if(input == TEXTBOX_INPUT.text) return val;
		return string(val);
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
				
				if(keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_enter)) {
				} else if(KEYBOARD_PRESSED == vk_backspace) {
					if(cursor_select == -1) {
						var str_before	= string_copy(_input_text, 1, cursor - 1);
						var str_after	= string_copy(_input_text, cursor + 1, string_length(_input_text) - cursor);
						
						_input_text		= str_before + str_after;
					} else {
						var minc = min(cursor, cursor_select);
						var maxc = max(cursor, cursor_select);
						
						var str_before	= string_copy(_input_text, 1, minc);
						var str_after	= string_copy(_input_text, maxc + 1, string_length(_input_text) - maxc);
						
						cursor = minc + 1;
						_input_text		= str_before + str_after;
					}
					
					cursor_select	= -1;
					move_cursor(-1);
				} else if(KEYBOARD_PRESSED == vk_delete || (keyboard_check_pressed(ord("X")) && key_mod_press(CTRL) && cursor_select != -1)) {
					if(cursor_select == -1) {
						var str_before	= string_copy(_input_text, 1, cursor);
						var str_after	= string_copy(_input_text, cursor + 2, string_length(_input_text) - cursor - 1);
						
						_input_text		= str_before + str_after;
					} else {
						var minc = min(cursor, cursor_select);
						var maxc = max(cursor, cursor_select);
						
						var str_before	= string_copy(_input_text, 1, minc);
						var str_after	= string_copy(_input_text, maxc + 1, string_length(_input_text) - maxc);
						
						cursor = minc;
						_input_text		= str_before + str_after;
					}
					cursor_select	= -1;
				} else if(KEYBOARD_STRING != "") {
					var ch			= KEYBOARD_STRING;
					
					if(cursor_select == -1) {
						var str_before	= string_copy(_input_text, 1, cursor);
						var str_after	= string_copy(_input_text, cursor + 1, string_length(_input_text) - cursor);
						
						_input_text		= str_before + ch + str_after;
						move_cursor(string_length(ch));
					} else {
						var minc = min(cursor, cursor_select);
						var maxc = max(cursor, cursor_select);
						
						var str_before	= string_copy(_input_text, 1, minc);
						var str_after	= string_copy(_input_text, maxc + 1, string_length(_input_text) - maxc);
						
						_input_text		= str_before + ch + str_after;
						cursor = minc + string_length(ch);
					}
					
					cursor_select	= -1;
				}
			}
			
			KEYBOARD_STRING = "";
			keyboard_lastkey = -1;
		#endregion
			
		if(keyboard_check_pressed(vk_home)) {
			if(keyboard_check(vk_shift)) {
				if(cursor_select == -1)
					cursor_select = cursor;
			} else 
				cursor_select	= -1;
			move_cursor(-cursor);
		} else if(keyboard_check_pressed(vk_end)) {
			if(keyboard_check(vk_shift)) {
				if(cursor_select == -1)
					cursor_select = cursor;
			} else 
				cursor_select	= -1;
			move_cursor(string_length(_input_text) - cursor);
		} else if(keyboard_check_pressed(vk_escape)) {
			_input_text = _last_text;
			apply();
			TEXTBOX_ACTIVE = noone;
		} else if(keyboard_check_pressed(vk_enter)) {
			apply();
			TEXTBOX_ACTIVE = noone;
		} else if(auto_update && keyboard_check_pressed(vk_anykey)) {
			apply();
		}
	}
	
	static display_text = function(_x, _y, _text, _w, _format, _m = -1) {
		BLEND_OVERRIDE
		
		switch(_format) {
			case VALUE_DISPLAY._default :
				draw_set_text(font == noone? f_p0 : font, fa_left, fa_top, color);
				draw_text(_x + disp_x, _y, _text);
				break;
			case VALUE_DISPLAY.export_format :
				draw_set_text(font == noone? f_p0 : font, fa_left, fa_top, color);
				var _x0 = _x + disp_x, ch = "", len = string_length(_text), i = 1;
				var cc = draw_get_color();
				var str = "", _comm = false;
				
				while(i <= len) {
					ch = string_char_at(_text, i);
					
					if(ch == "%")
						_comm = true;
					
					if(!_comm) {
						draw_text(_x0, 0, ch);
						_x0 += string_width(ch);
					} else {
						str += ch;
						switch(ch) {
							case "d" : draw_set_color(COLORS.widget_text_dec_d); break;	
							case "n" : draw_set_color(COLORS.widget_text_dec_n); break;	
							case "e" : draw_set_color(COLORS.widget_text_dec_e); break;	
							case "f" : draw_set_color(COLORS.widget_text_dec_f); break;	
							case "i" : draw_set_color(COLORS.widget_text_dec_i); break;
						}
						
						switch(ch) {
							case "d" :	case "n" :	case "e" :	case "f" :	case "i" : 
								draw_text(_x0, 0, str);
								_x0 += string_width(str);
								_comm = false; 
								str = "";
								
								draw_set_color(cc);
								break;
						}
					}
					
					i++;
				}
				
				draw_text(_x0, _y, str);
				break;
		}
		
		BLEND_NORMAL
		
		var _xx = _x, _ch, _chw;
		var target = -999;
		
		if(!sliding && _m != -1) {
			for( var i = 1; i <= string_length(_text); i++ ) {
				_ch = string_char_at(_text, i);
				_chw = string_width(_ch);
						
				if(_m < _xx + _chw / 2) {
					target = i - 1;
					break;
				} else if(_m < _xx + _chw) {
					target = i;
					break;
				}
				_xx += _chw;
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
	
	static draw = function(_x, _y, _w, _h, _text, _m, _format = VALUE_DISPLAY._default, halign = fa_left, valign = fa_top) {
		if(extras && instanceof(extras) == "buttonClass") {
			extras.hover  = hover;
			extras.active = active;
			
			extras.draw(_x + _w - ui(32), _y + _h / 2 - ui(32 / 2), ui(32), ui(32), _m, THEME.button_hide);
			_w -= ui(40);
		}
		
		if(sliding > 0) {
			var dx =   _m[0] - slide_mx;
			var dy = -(_m[1] - slide_my);
			
			if(sliding == 1 && (abs(dx) > 16 || abs(dy) > 16)) {
				sliding = 2;
				slide_mx = _m[0];
				slide_my = _m[1];
				
				dx = 0;
				dy = 0;
			}
			
			if(sliding == 2) {
				var _ip = _input_text;
				
				if(!MOUSE_WRAPPING) {
					var spd = (abs(dx) > abs(dy)? dx : dy) * slide_speed;
				
					if(keyboard_check(vk_alt))
						spd /= 10;
					if(key_mod_press(CTRL))
						spd *= 10;
					
					_input_text = _input_text + spd;
				
					switch(input) {
						case TEXTBOX_INPUT.number :	_input_text = round(_input_text);	break;
					}
					
					apply();
					UNDO_HOLDING = true;
				}
				
				if(MOUSE_WRAPPING || _input_text != _ip) {
					slide_mx = _m[0];
					slide_my = _m[1];
				}
				
				setMouseWrap();
				if(mouse_release(mb_left)) {
					UNDO_HOLDING = false;
					TEXTBOX_ACTIVE = noone;
				}
			}
			
			if(mouse_release(mb_left))
				sliding = 0;
		}
		
		
		var _dpX = _x + ui(8);
		var _dpY = _y;
		
		switch(halign) {
			case fa_left:   _x = _x;			break;	
			case fa_center: _x = _x - _w / 2;	break;	
			case fa_right:  _x = _x - _w;		break;	
		}
		
		switch(valign) {
			case fa_top:    _y = _y;			break;	
			case fa_center: _y = _y - _h / 2;	break;	
			case fa_bottom: _y = _y - _h;		break;	
		}
		
		draw_set_text(font == noone? f_p0 : font, fa_left, fa_top);
		
		var tx = _x;
		switch(align) {
			case fa_left   : tx = _x + ui(8); break;
			case fa_center : tx = _x + _w / 2; break;
			case fa_right  : tx = _x + _w - ui(8); break;
		}
		
		text_surface = surface_verify(text_surface, _w - ui(16), _h);
		draw_sprite_stretched(THEME.textbox, 3, _x, _y, _w, _h);
		disp_x = lerp_float(disp_x, disp_x_to, 5);
		
		if(self == TEXTBOX_ACTIVE) { 
			draw_sprite_stretched(THEME.textbox, sprite_index == -1? 2 : sprite_index, _x, _y, _w, _h);
			editText();
			
			#region cursor position
				if(KEYBOARD_PRESSED == vk_left) {
					if(keyboard_check(vk_shift)) {
						if(cursor_select == -1)
							cursor_select = cursor;
					} else 
						cursor_select	= -1;
						
					move_cursor(-1);
				}
				if(KEYBOARD_PRESSED == vk_right) {
					if(keyboard_check(vk_shift)) {
						if(cursor_select == -1)
							cursor_select = cursor;
					} else 
						cursor_select	= -1;
					
					move_cursor(1);
				}
			#endregion
			
			#region multiplier
				if(_w > ui(80) && (input == TEXTBOX_INPUT.number || input == TEXTBOX_INPUT.float)) {
					draw_set_text(f_p0b, fa_left, fa_center, COLORS._main_text_sub);
					draw_set_alpha(0.5);
				
					if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + ui(32), _y + _h)) {
						draw_set_alpha(1);
					
						if(mouse_press(mb_left, active)) {
							var ktxt = _input_text;
							if(input == TEXTBOX_INPUT.number) {
								if(keyboard_check(vk_alt))	_input_text	= string(ceil(toNumber(ktxt) / 2));
								else						_input_text	= string(ceil(toNumber(ktxt) * 2));
							} else {
								if(keyboard_check(vk_alt))	_input_text	= string(toNumber(ktxt) / 2);
								else						_input_text	= string(toNumber(ktxt) * 2);
							}
							apply();
						}
					}
				
					if(keyboard_check(vk_alt))
						draw_text(_x + ui(8), _y + _h / 2, "/2");
					else
						draw_text(_x + ui(8), _y + _h / 2, "x2");
					draw_set_alpha(1);
				}
			#endregion
			
			#region draw
				var txt = getDisplayText(_input_text);
				draw_set_text(font == noone? f_p0 : font, fa_left, fa_top);
				var tw = string_width(txt);
				var th = string_height(txt);
				
				var cs   = string_copy(txt, 1, cursor);
				var c_w  = string_width(cs);
				var c_y0 = _y + _h / 2 - th / 2;
				var c_y1 = _y + _h / 2 + th / 2;
				
				switch(align) {
					case fa_left   :
						disp_x_min = -max(0, tw - _w + ui(16 + 8));
						disp_x_max = 0;
						break;
					case fa_center : 
						disp_x_min = -max(0, tw - _w + ui(16 + 8)) / 2;
						disp_x_max =  max(0, tw - _w + ui(16 + 8)) / 2;
						tx -= tw / 2;	
						break;
					case fa_right  :
						disp_x_min = 0;
						disp_x_max = max(0, tw - _w + ui(16 + 8));
						tx -= tw;		
						break;
				}
				
				cursor_pos_to	= disp_x + tx + c_w;
				if(cursor_pos_to < _x)  
					disp_x_to += _w - ui(16);
				if(cursor_pos_to > _x + _w - ui(16))  
					disp_x_to -= _w - ui(16);
					
				//print("Cursor x : " + string(cursor_pos_to) + ", Display x : " + string(_x) + ", to x : " + string(disp_x_to) + ", max x : " + string(disp_x_max));
				
				cursor_pos		= cursor_pos == 0? cursor_pos_to : lerp_float(cursor_pos, cursor_pos_to, 4);
				
				if(cursor_select > -1) { //draw highlight
					draw_set_color(COLORS.widget_text_highlight);
					var x1 = tx + string_width(string_copy(txt, 1, cursor_select));
					
					draw_roundrect_ext(cursor_pos, c_y0, x1, c_y1, ui(8), ui(8), 0);
				}
				
				var _mx = -1;
				var _my = -1;
				if(mouse_press(mb_any, active) && hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
					_mx = _m[0];
					_my = _m[1];
				}
				
				surface_set_target(text_surface);
				draw_clear_alpha(0, 0);
					display_text(tx - _dpX, _h / 2 - th / 2, txt, _w - ui(4), _format, _mx);
				surface_reset_target();
				draw_surface(text_surface, _dpX, _dpY);
		
				draw_set_color(COLORS._main_text_accent);
				draw_line_width(cursor_pos, c_y0, cursor_pos, c_y1, 2);
			#endregion
			
			disp_x_to = clamp(disp_x_to, disp_x_min, disp_x_max);
			
			if(!point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h) && mouse_press(mb_left)) {
				apply();
				TEXTBOX_ACTIVE = noone;
			}
		} else {
			var txt = getDisplayText(_text);
			draw_set_text(font == noone? f_p0 : font, fa_left, fa_center);
			var tw = string_width(txt);
			var th = string_height(txt);
				
			switch(align) {
				case fa_left   :				break;
				case fa_center : tx -= tw / 2;	break;
				case fa_right  : tx -= tw;		break;
			}
			
			if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
				if(hide)
					draw_sprite_stretched_ext(THEME.textbox, 1, _x, _y, _w, _h, c_white, 0.5);	
				else
					draw_sprite_stretched(THEME.textbox, 1, _x, _y, _w, _h);	
				if(mouse_press(mb_left, active)) {
					TEXTBOX_ACTIVE  = self;
					click_block = 1;
					KEYBOARD_STRING = "";
					keyboard_lastkey = -1;
				
					_input_text	= _text;
					_last_text  = _text;
				}
			} else if(!hide) {
				draw_sprite_stretched(THEME.textbox, 0, _x, _y, _w, _h);
			}
			
			if(slidable) {
				if(_w > ui(64))
					draw_sprite_ui_uniform(THEME.text_slider, 0, _x + ui(20), _y + _h / 2, 1, COLORS._main_icon, 0.5);
				
				if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
					if(mouse_press(mb_left, active)) {
						sliding  = 1;
						
						slide_mx = _m[0];
						slide_my = _m[1];
					}
				} 
			}
			
			surface_set_target(text_surface);
			draw_clear_alpha(0, 0);
				display_text(tx - _dpX, _h / 2 - th / 2, txt, _w - ui(4), _format);
			surface_reset_target();
			draw_surface(text_surface, _dpX, _dpY);
		}
		
		hover  = false;
		active = false;
		
		sprite_index = -1;
		return _h;
	}
}