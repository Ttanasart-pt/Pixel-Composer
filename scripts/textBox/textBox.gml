enum TEXTBOX_INPUT {
	text,
	number
}

function textBox(_input, _onModify) : textInput(_input, _onModify) constructor {
	align  = _input == TEXTBOX_INPUT.number? fa_right : fa_left;
	hide   = false;
	font   = noone;
	color  = COLORS._main_text;
	boxColor = c_white;
	format = TEXT_AREA_FORMAT._default;
	
	no_empty    = true;
	auto_update = false;
	
	slidable = false;
	sliding  = false;
	slide_sv = 0;
	slide_speed = 1 / 10;
	
	starting_char = 1;
	
	_current_text = "";
	_input_text   = "";
	_last_text    = "";
	current_value = "";
	
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
	
	static setSlidable = function(slideStep = slide_speed) { #region
		slidable    = true;
		slide_speed = slideStep;
		
		return self;
	} #endregion
	
	static setFont = function(font) { #region
		self.font = font;
		return self;
	} #endregion
	
	static setEmpty = function() { #region
		no_empty = false;
		return self;
	} #endregion
	
	static activate = function() { #region
		WIDGET_CURRENT = self;
		WIDGET_CURRENT_SCROLL = parent;
		parentFocus();
		
		_input_text	= _current_text;
		_last_text  = _current_text;
		
		cursor_select = 0;
		cursor = string_length(_current_text);
					
		click_block = 1;
		KEYBOARD_STRING = "";
		keyboard_lastkey = -1;
	} #endregion
	
	static deactivate = function() { #region
		if(WIDGET_CURRENT != self) return;
		
		apply();
		WIDGET_CURRENT = noone;
		UNDO_HOLDING = false;
	} #endregion
	
	static onKey = function(key) { #region
		if(KEYBOARD_PRESSED == vk_left) {
			if(key_mod_press(SHIFT)) {
				if(cursor_select == -1)
					cursor_select = cursor;
			} else if(cursor_select != -1)
				cursor_select = -1;
			else 
				move_cursor(-1);
		}
				
		if(KEYBOARD_PRESSED == vk_right) {
			if(key_mod_press(SHIFT)) {
				if(cursor_select == -1)
					cursor_select = cursor;
			} else if(cursor_select != -1)
				cursor_select = -1;
			else 
				move_cursor(1);
		}
	} #endregion
	
	static apply = function() { #region
		var _input_text_current = _input_text;
		disp_x_to = 0;
		
		if(input == TEXTBOX_INPUT.number)
			_input_text_current = evaluateFunction(_input_text);
		
		if(no_empty && _input_text_current == "") 
			_input_text_current = _last_text;
		current_value = _input_text_current;
		
		if(is_callable(onModify))
			return onModify(_input_text_current);
		return false;
	} #endregion
	
	static move_cursor = function(delta) { #region
		var ll = string_length(_input_text) + 1;
		cursor = safe_mod(cursor + delta + ll, ll);
	} #endregion
	
	static editText = function() { #region
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
						var str_before, str_after;
						
						if(key_mod_press(CTRL)) {
							var _c = cursor - 1;
							while(_c > 0) {
								var ch = string_char_at(_input_text, _c);
								if(breakCharacter(ch)) break;
								_c--;
							}
							
							str_before	= string_copy(_input_text, 1, _c);
							str_after	= string_copy(_input_text, cursor + 1, string_length(_input_text) - cursor);
							cursor = _c + 1;
						} else {
							str_before	= string_copy(_input_text, 1, cursor - 1);
							str_after	= string_copy(_input_text, cursor + 1, string_length(_input_text) - cursor);
						}
						
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
		
		if(keyboard_check_pressed(vk_left))	 onKey(vk_left);
		if(keyboard_check_pressed(vk_right)) onKey(vk_right);
		
		if(input == TEXTBOX_INPUT.number) {
			var _inc = 1;
			if(key_mod_press(CTRL)) _inc *= 10;
			if(key_mod_press(ALT))  _inc /= 10;
			
			if(KEYBOARD_PRESSED == vk_up   || keyboard_check_pressed(vk_up))   { _input_text = string(toNumber(_input_text) + _inc); apply(); }
			if(KEYBOARD_PRESSED == vk_down || keyboard_check_pressed(vk_down)) { _input_text = string(toNumber(_input_text) - _inc); apply(); }
		}
		
		if(keyboard_check_pressed(vk_home)) {
			if(key_mod_press(SHIFT)) {
				if(cursor_select == -1)
					cursor_select = cursor;
			} else 
				cursor_select	= -1;
			move_cursor(-cursor);
		} else if(keyboard_check_pressed(vk_end)) {
			if(key_mod_press(SHIFT)) {
				if(cursor_select == -1)
					cursor_select = cursor;
			} else 
				cursor_select	= -1;
			move_cursor(string_length(_input_text) - cursor);
		} else if(keyboard_check_pressed(vk_escape)) {
			_input_text = _last_text;
			deactivate();
		} else if(keyboard_check_pressed(vk_enter))
			deactivate();
		else if(auto_update && keyboard_check_pressed(vk_anykey))
			apply();
	} #endregion
	
	static display_text = function(_x, _y, _text, _w, _m = -1) { #region
		_text = string_real(_text);
		draw_set_alpha(0.5 + 0.5 * interactable);
		
		switch(format) {
			case TEXT_AREA_FORMAT._default :
				draw_set_text(font == noone? f_p0 : font, fa_left, fa_top, color);
				draw_text_add(_x + disp_x, _y, _text);
				break;
			case TEXT_AREA_FORMAT.node_title :
				draw_set_text(font == noone? f_p0 : font, fa_left, fa_top, color);
				draw_text_add(_x + disp_x, _y, _text);
				break;
		}
		
		draw_set_alpha(1);
		
		var _xx = _x + disp_x;
		var _mm = _m;
		var target = -999;
		
		if(!sliding && _mm >= 0) {
			for( var i = 1; i <= string_length(_text); i++ ) {
				var _ch  = string_char_at(_text, i);
				var _chw = string_width(_ch);
						
				if(_mm < _xx + _chw / 2) {
					target = i - 1;
					break;
				} else if(_mm < _xx + _chw) {
					target = i;
					break;
				}
				
				_xx += _chw;
			}
		}
		
		if(target != -999) {
			if(mouse_press(mb_left, active) && !click_block) {
				cursor_select = target;
				cursor		  = target;	
			} else if(mouse_click(mb_left, active) && cursor != target)
				cursor = target;	
				
			if(mouse_press(mb_left, active))
				click_block	  = false;
		}
	} #endregion
	
	static drawParam = function(params) { #region
		return draw(params.x, params.y, params.w, params.h, params.data, params.m, params.halign, params.valign);
	} #endregion
	
	static draw = function(_x, _y, _w, _h, _text = "", _m = mouse_ui, halign = fa_left, valign = fa_top) { #region
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
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
		
		if(side_button && instanceof(side_button) == "buttonClass") {
			side_button.setFocusHover(active, hover);
			side_button.draw(_x + _w - ui(32), _y + _h / 2 - ui(32 / 2), ui(32), ui(32), _m, THEME.button_hide);
			_w -= ui(40);
		}
		
		draw_set_font(font == noone? f_p0 : font);
		var _raw_text = _text;
		_text = string_real(_text);
		_current_text = _text;
		
		var tb_surf_x = _x + ui(8);
		var tb_surf_y = _y;
		
		draw_set_text(font == noone? f_p0 : font, fa_left, fa_top);
		
		var tx = _x;
		switch(align) {
			case fa_left   : tx = _x + ui(8); break;
			case fa_center : tx = _x + _w / 2; break;
			case fa_right  : tx = _x + _w - ui(8); break;
		}
		
		text_surface = surface_verify(text_surface, _w - ui(16), _h);
		if(!hide) draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, _w, _h, boxColor, 1);
		disp_x = lerp_float(disp_x, disp_x_to, 5);
		
		var hoverRect = point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h);
		
		if(selecting) { 
			if(sprite_index == -1)
				draw_sprite_stretched_ext(THEME.textbox, 2, _x, _y, _w, _h, COLORS._main_accent, 1);
			else 
				draw_sprite_stretched(THEME.textbox, sprite_index, _x, _y, _w, _h);
			editText();
			
			#region multiplier
				if(_w > ui(80) && input == TEXTBOX_INPUT.number) {
					draw_set_text(f_p0b, fa_left, fa_center, COLORS._main_text_sub);
					draw_set_alpha(0.5);
				
					if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + ui(32), _y + _h)) {
						draw_set_alpha(1);
					
						if(mouse_press(mb_left, active)) {
							if(key_mod_press(ALT))	_input_text	= string_real(toNumber(_input_text) / 2);
							else					_input_text	= string_real(toNumber(_input_text) * 2);
							apply();
						}
					}
				
					if(key_mod_press(ALT))
						draw_text_add(_x + ui(8), _y + _h / 2, "/2");
					else
						draw_text_add(_x + ui(8), _y + _h / 2, "x2");
					draw_set_alpha(1);
				}
			#endregion
			
			#region draw
				var txt = _input_text;
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
				
				cursor_pos		= cursor_pos == 0? cursor_pos_to : lerp_float(cursor_pos, cursor_pos_to, 2);
				
				if(cursor_select > -1) { //draw highlight
					draw_set_color(COLORS.widget_text_highlight);
					var x1 = tx + string_width(string_copy(txt, 1, cursor_select));
					
					draw_roundrect_ext(cursor_pos, c_y0, x1, c_y1, THEME_VALUE.highlight_corner_radius, THEME_VALUE.highlight_corner_radius, 0);
				}
				
				var _mx = -1;
				var _my = -1;
				if(hover && hoverRect) {
					_mx = _m[0];
					_my = _m[1];
				}
				
				surface_set_shader(text_surface, noone, true, BLEND.add);
					display_text(tx - tb_surf_x, _h / 2 - th / 2, txt, _w - ui(4), _mx - tb_surf_x);
				surface_reset_shader();
				
				BLEND_ALPHA
				draw_surface(text_surface, tb_surf_x, tb_surf_y);
				BLEND_NORMAL
		
				draw_set_color(COLORS._main_text_accent);
				draw_line_width(cursor_pos, c_y0, cursor_pos, c_y1, 2);
			#endregion
			
			disp_x_to = clamp(disp_x_to, disp_x_min, disp_x_max);
			
			if(!hoverRect && mouse_press(mb_left)) 
				deactivate();
		} else { #region draw
			draw_set_text(font == noone? f_p0 : font, fa_left, fa_center);
			var _display_text = _raw_text;
			if(input == TEXTBOX_INPUT.number) {
				var dig = floor(_w / string_width("0")) - 3;
				_display_text = string_real(_display_text, dig);
			}
			var tw = string_width(_display_text);
			var th = string_height(_display_text);
				
			switch(align) {
				case fa_left   :				break;
				case fa_center : tx -= tw / 2;	break;
				case fa_right  : tx -= tw;		break;
			}
			
			if(hover && hoverRect) {
				if(hide)
					draw_sprite_stretched_ext(THEME.textbox, 1, _x, _y, _w, _h, boxColor, 0.5);	
				else
					draw_sprite_stretched_ext(THEME.textbox, 1, _x, _y, _w, _h, boxColor, 0.5 + 0.5 * interactable);	
				if(mouse_press(mb_left, active))
					activate();
				
				if(input == TEXTBOX_INPUT.number && key_mod_press(SHIFT)) {
					var amo = slide_speed;
					if(key_mod_press(CTRL)) amo *= 10;
					if(key_mod_press(ALT))  amo /= 10;
					
					if(mouse_wheel_down())	onModify(toNumber(_text) + amo * SCROLL_SPEED);
					if(mouse_wheel_up())	onModify(toNumber(_text) - amo * SCROLL_SPEED);
				}
			} else if(!hide)
				draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _w, _h, boxColor, 0.5 + 0.5 * interactable);
			
			if(slidable) {
				if(_w > ui(64))
					draw_sprite_ui_uniform(THEME.text_slider, 0, _x + ui(20), _y + _h / 2, 1, COLORS._main_icon, 0.5);
				
				if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h) && mouse_press(mb_left, active)) {
					sliding  = 1;
						
					slide_mx = _m[0];
					slide_my = _m[1];
				} 
			}
			
			surface_set_shader(text_surface, noone, true, BLEND.add);
				display_text(tx - tb_surf_x, _h / 2 - th / 2, _display_text, _w - ui(4));
			surface_reset_shader();
			
			BLEND_ALPHA
			draw_surface(text_surface, tb_surf_x, tb_surf_y);
			BLEND_NORMAL
		} #endregion
		
		if(sliding > 0) { #region
			var dx = _m[0] - slide_mx;
			var dy = _m[1] - slide_my;
			
			if(sliding == 1 && (abs(dx) > 16 || abs(dy) > 16)) {
				sliding  = 2;
				slide_sv = toNumber(_input_text);
				o_dialog_textbox_slider.activate()
			}
			
			if(sliding == 2) {
				o_dialog_textbox_slider.tb = self;
				
				if(mouse_release(mb_left)) deactivate();
			}
			
			if(mouse_release(mb_left)) {
				sliding = 0;
				UNDO_HOLDING = false;
			}
		} #endregion
		
		if(DRAGGING && (DRAGGING.type == "Text" || DRAGGING.type == "Number") && hover && hoverRect) {
			draw_sprite_stretched_ext(THEME.ui_panel_active, 0, _x, _y, _w, _h, COLORS._main_value_positive, 1);
			if(mouse_release(mb_left))
				onModify(DRAGGING.data);
		}
		
		selecting = self == WIDGET_CURRENT;
		resetFocus();		
		sprite_index = -1;
		return _h;
	} #endregion
}