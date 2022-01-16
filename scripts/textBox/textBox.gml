enum TEXTBOX_INPUT {
	text,
	number,
	float
}

function textBox(_input, _onModify) constructor {
	active = false;
	hover  = false;
	font   = f_p0;
	align  = fa_right;
	hide   = false;
	
	no_empty    = true;
	auto_update = false;
	
	slidable = false;
	sliding  = false;
	slide_mx = 0;
	slide_sx = 0;
	slide_speed = 1 / 16;
	
	input = _input;
	onModify = _onModify;
	
	_input_text = "";
	_last_value = "";
	
	cursor			= 0;
	cursor_pos		= 0;
	cursor_pos_to	= 0;
	
	cursor_select	= -1;
	
	click_block = 0;
	
	function apply() {
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
			_input_text_current = _last_value;
		if(onModify) 
			onModify(_input_text_current);
	}
	
	function move_cursor(delta) {
		var ll = string_length(_input_text) + 1;
		cursor = safe_mod(cursor + delta + ll, ll);
	}
	
	function editText() {
		#region text editor
			if(keyboard_check_released(ord("V")) && keyboard_check(vk_control))
				_input_text = clipboard_get_text();
			
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
					} else {
						var minc = min(cursor, cursor_select);
						var maxc = max(cursor, cursor_select);
						
						var str_before	= string_copy(_input_text, 1, minc);
						var str_after	= string_copy(_input_text, maxc + 2, string_length(_input_text) - maxc - 1);
						
						_input_text		= str_before + str_after;
					}
					
					cursor_select	= -1;
					move_cursor(-1);
				} else if(keyboard_check_pressed(vk_delete)) {
					if(cursor_select == -1) {
						var str_before	= string_copy(_input_text, 1, cursor);
						var str_after	= string_copy(_input_text, cursor + 2, string_length(_input_text) - cursor - 1);
					
						_input_text		= str_before + str_after;
					} else {
						var minc = min(cursor, cursor_select);
						var maxc = max(cursor, cursor_select);
						
						var str_before	= string_copy(_input_text, 1, minc);
						var str_after	= string_copy(_input_text, maxc + 2, string_length(_input_text) - maxc - 1);
						
						_input_text		= str_before + str_after;
					}
					cursor_select	= -1;
				} else if(keyboard_string != "") {
					var ch			= keyboard_string;
					
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
						cursor = min(cursor, cursor_select) + string_length(ch);
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
			apply();
			TEXTBOX_ACTIVE = noone;
		} else if(keyboard_check_pressed(vk_enter)) {
			apply();
			TEXTBOX_ACTIVE = noone;
		}
	}
	
	function display_text(_x, _y, _text, _w, _format, _m = -1) {
		var _xx = _x, _ch, _chw;
		var target = -999;
		
		switch(_format) {
			case VALUE_DISPLAY._default :
				draw_set_text(font, fa_left, fa_center, c_white);
				draw_text(_x, _y, _text);
				break;
			case VALUE_DISPLAY.export_format :
				draw_set_text(font, fa_left, fa_center, c_white);
				var _x0 = _x, ch = "", len = string_length(_text), i = 1;
				var cc = draw_get_color();
				var str = "", _comm = false;
				
				while(i <= len) {
					ch = string_char_at(_text, i);
					
					if(ch == "%")
						_comm = true;
					
					if(!_comm) {
						draw_text(_x0, _y, ch);
						_x0 += string_width(ch);
					} else {
						str += ch;
						switch(ch) {
							case "d" : draw_set_color(c_ui_cyan);	break;	
							case "n" : draw_set_color(c_ui_lime);	break;	
							case "e" : draw_set_color(c_ui_orange); break;	
							case "f" : draw_set_color(c_ui_pink);	break;	
							case "i" : draw_set_color(c_ui_yellow); break;
						}
						
						switch(ch) {
							case "d" :	case "n" :	case "e" :	case "f" :	case "i" : 
								draw_text(_x0, _y, str);
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
			if(mouse_check_button_pressed(mb_left) || click_block == 1) {
				cursor_select = -1;
				cursor = target;
				click_block = 0;
			} else if(mouse_check_button(mb_left) && cursor != target) {
				cursor_select = target;
			}
		}
	}
	
	function draw(_x, _y, _w, _h, _text, _m, _format = VALUE_DISPLAY._default) {
		var tx = _x;
		switch(align) {
			case fa_left   : tx = _x + 8; break;
			case fa_center : tx = _x + _w / 2; break;
			case fa_right  : tx = _x + _w - 8; break;
		}
		
		if(sliding > 0) {
			var dx = _m[0] - slide_mx;
			if(abs(dx) > 16)
				sliding = 2;
			
			if(sliding == 2) {
				_input_text = slide_sx + dx * slide_speed;
				
				switch(input) {
					case TEXTBOX_INPUT.number :
						_input_text = round(_input_text);
						break;
				} 
				
				if(mouse_check_button_released(mb_left)) {
					apply();
					TEXTBOX_ACTIVE = noone;
				}
			}
			
			if(mouse_check_button_released(mb_left)) {
				sliding = 0;
			}
		}
		
		if(self == TEXTBOX_ACTIVE) { 
			draw_sprite_stretched(s_textbox, 2, _x, _y, _w, _h);
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
			#endregion
			
			#region multiplier
				if(_w > 80 && (input == TEXTBOX_INPUT.number || input == TEXTBOX_INPUT.float)) {
					draw_set_text(f_p0b, fa_left, fa_center, c_ui_blue_ltgrey);
					draw_set_alpha(0.5);
				
					if(point_in_rectangle(_m[0], _m[1], _x, _y, _x + 32, _y + _h)) {
						draw_set_alpha(1);
					
						if(active && mouse_check_button_pressed(mb_left)) {
							var ktxt = _input_text;
							if(input == TEXTBOX_INPUT.number) {
								if(keyboard_check(vk_alt))	_input_text	= string(ceil(toNumber(ktxt) / 2));
								else						_input_text	= string(ceil(toNumber(ktxt) * 2));
							} else {
								if(keyboard_check(vk_alt))	_input_text	= string(toNumber(ktxt) / 2);
								else						_input_text	= string(toNumber(ktxt) * 2);
							}
						}
					}
				
					if(keyboard_check(vk_alt))
						draw_text(_x + 8, _y + _h / 2, "/2");
					else
						draw_text(_x + 8, _y + _h / 2, "x2");
					draw_set_alpha(1);
					
					apply();
				}
			#endregion
			
			#region draw
				var ss = string_cut(_input_text, _w - 4);
				draw_set_text(font, fa_left, fa_center, c_white);
				var ww = string_width(ss);
				
				switch(align) {
					case fa_left   :				break;
					case fa_center : tx -= ww / 2;	break;
					case fa_right  : tx -= ww;		break;
				}
				
				var cs   = string_copy(ss, 1, cursor);
				var c_w  = string_width(cs);
				var c_h  = string_height(ss);
				var c_y0 = _y + _h / 2 - c_h / 2;
				var c_y1 = _y + _h / 2 + c_h / 2;
				cursor_pos_to	= tx + c_w;
				cursor_pos		= cursor_pos == 0? cursor_pos_to : lerp_float(cursor_pos, cursor_pos_to, 3);
				
				if(cursor_select > -1) {
					draw_set_color(c_ui_blue_grey);
					var x1 = tx + string_width(string_copy(_input_text, 1, cursor_select));
					
					draw_rectangle(cursor_pos, c_y0, x1, c_y1, 0);
				}
				
				var _mx = -1;
				if((mouse_check_button_pressed(mb_left) || mouse_check_button(mb_left)) && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
					_mx = _m[0];
				}
				
				draw_set_color(c_white);
				display_text(tx, _y + _h / 2, ss, _w - 4, _format, _mx);
				draw_set_color(c_ui_orange);
				draw_line_width(cursor_pos, c_y0, cursor_pos, c_y1, 2);
			#endregion
			
			if(!point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h) && mouse_check_button_pressed(mb_left)) {
				apply();
				TEXTBOX_ACTIVE = noone;
			}
		} else {
			var ss = string_cut(string(_text), _w - 4);
			draw_set_text(font, fa_left, fa_center, c_white);
			var ww = string_width(ss);
				
			switch(align) {
				case fa_left   :				break;
				case fa_center : tx -= ww / 2;	break;
				case fa_right  : tx -= ww;		break;
			}
			
			if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
				if(hide)
					draw_sprite_stretched_ext(s_textbox, 1, _x, _y, _w, _h, c_white, 0.5);	
				else
					draw_sprite_stretched(s_textbox, 1, _x, _y, _w, _h);	
				if(active && mouse_check_button_pressed(mb_left)) {
					TEXTBOX_ACTIVE  = self;
					click_block = 1;
					keyboard_string = "";
					keyboard_lastkey = -1;
				
					_input_text		= _text;
					_last_value     = _text;
				}
			} else if(!hide) {
				draw_sprite_stretched(s_textbox, 0, _x, _y, _w, _h);
			}
			
			display_text(tx, _y + _h / 2, ss, _w - 4, _format);
			
			if(slidable) {
				draw_sprite_ext(s_text_slider, 0, _x + 20, _y + _h / 2, 1, 1, 0, c_ui_blue_grey, 0.5);
			
				if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
					if(active && mouse_check_button_pressed(mb_left)) {
						sliding  = 1;
						slide_mx = _m[0];
						slide_sx = _last_value;
					}
				} 
			}
		}
		
		hover  = false;
		active = false;
	}
}