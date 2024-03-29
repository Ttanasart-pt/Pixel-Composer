enum TEXTBOX_INPUT {
	text,
	number
}

function textBox(_input, _onModify) : textInput(_input, _onModify) constructor {
	onRelease = noone;
	
	align  = _input == TEXTBOX_INPUT.number? fa_center : fa_left;
	hide   = false;
	color  = COLORS._main_text;
	boxColor  = c_white;
	format    = TEXT_AREA_FORMAT._default;
	precision = 5;
	
	suffix = "";
	
	no_empty    = true;
	auto_update = false;
	
	slidable    = false;
	sliding     = false;
	slide_delta = 0;
	slide_int   = false;
	slide_speed = 1 / 10;
	slide_snap  = 0;
	slide_range = noone;
	curr_range  = [ 0, 1 ];
	
	label = "";
	
	starting_char = 1;
	
	_current_text = "";
	_input_text   = "";
	_last_text    = "";
	current_value = "";
	_disp_text    = "";
	
	cursor			= 0;
	cursor_pos		= 0;
	cursor_pos_y	= 0;
	cursor_pos_to	= 0;
	cursor_select	= -1;
	
	disp_x		= 0;
	disp_x_to	= 0;
	disp_x_min	= 0;
	disp_x_max	= 0;
	
	click_block = 0;
	
	use_range = false;
	range_min = 0;
	range_max = 0;
	
	disp_text_fx = [];
	
	sprite_index = -1;
	
	text_surface = surface_create(1, 1);
	
	shake_amount = 0;
	
	static setOnRelease = function(release) { onRelease = release; return self; }
	
	static modifyValue = function(value) { #region
		if(input == TEXTBOX_INPUT.number) {
			if(use_range) value = clamp(value, range_min, range_max);
		}
		
		onModify(value);
	} #endregion
	
	static setSlidable = function(slideStep = slide_speed, _slide_int = false, _slide_range = noone) { #region
		slidable    = true;
		slide_speed = is_array(slideStep)? slideStep[0] : slideStep;
		slide_snap  = is_array(slideStep)? slideStep[1] : 0;
		slide_int   = _slide_int;
		slide_range = _slide_range;
		
		return self;
	} #endregion
	
	static setRange = function(_rng_min, _rng_max) { #region
		use_range = true;
		range_min = _rng_min;
		range_max = _rng_max;
		
		return self;
	} #endregion
	
	static setFont = function(font) { #region
		self.font = font;
		return self;
	} #endregion
	
	static setLabel = function(label) { #region
		self.label = label;
		return self;
	} #endregion
	
	static setPrecision = function(precision) { #region
		self.precision = precision;
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
		
		cursor        = string_length(_current_text);
		cursor_select = 0;
		click_block   = 1;
		
		KEYBOARD_STRING = "";
		keyboard_lastkey = -1;
		
		if(PEN_USE) keyboard_virtual_show(input == TEXTBOX_INPUT.number? kbv_type_numbers : kbv_type_default, kbv_returnkey_default, kbv_autocapitalize_none, true);
	} #endregion
	
	static deactivate = function() { #region
		if(WIDGET_CURRENT != self) return;
		
		apply();
		WIDGET_CURRENT = noone;
		UNDO_HOLDING = false;
		
		if(PEN_USE) keyboard_virtual_hide();
	} #endregion
	
	static onKey = function(key) { #region
		if(KEYBOARD_PRESSED == vk_left) {
			if(key_mod_press(SHIFT)) {
				if(cursor_select == -1)
					cursor_select = cursor;
			} else if(cursor_select != -1)
				cursor_select = -1;
			
			move_cursor(-1);
		}
				
		if(KEYBOARD_PRESSED == vk_right) {
			if(key_mod_press(SHIFT)) {
				if(cursor_select == -1)
					cursor_select = cursor;
			} else if(cursor_select != -1)
				cursor_select = -1;
			
			move_cursor(1);
		}
	} #endregion
	
	static apply = function(fn = onModify) { #region
		var _input_text_current = _input_text;
		disp_x_to = 0;
		
		if(input == TEXTBOX_INPUT.number)
			_input_text_current = evaluateFunction(_input_text);
		
		if(no_empty && _input_text_current == "") 
			_input_text_current = _last_text;
		current_value = _input_text_current;
		
		if(is_callable(fn)) {
			var _modi = fn(_input_text_current);
			if(_modi && IS_PATREON) shake_amount = PREFERENCES.textbox_shake / 4;
			return _modi;
		}
		
		if(IS_PATREON) shake_amount = PREFERENCES.textbox_shake / 4;
		return false;
	} #endregion
	
	static move_cursor = function(delta) { #region
		var ll = string_length(_input_text) + 1;
		cursor = safe_mod(cursor + delta + ll, ll);
	} #endregion
	
	static editText = function() { #region
		var edited = false;
		
		#region text editor
			if(key_mod_press(CTRL) && keyboard_check_pressed(ord("A"))) {
				cursor_select	= 0;
				cursor			= string_length(_input_text);
			} else if(key_mod_press(CTRL) && (keyboard_check_pressed(ord("C")) || keyboard_check_pressed(ord("X")))) {
				if(cursor_select != -1) {
					var minc = min(cursor, cursor_select);
					var maxc = max(cursor, cursor_select);
					clipboard_set_text(string_copy(_input_text, minc + 1, maxc - minc));
				}
			} else {
				if(key_mod_press(CTRL) && keyboard_check_pressed(ord("V"))) {
					KEYBOARD_STRING = clipboard_get_text();
					edited = true;
				}
					
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
					
					edited = true;
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
					
					edited = true;
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
					
					edited = true;
					cursor_select	= -1;
				}
			}
			
			KEYBOARD_STRING  = "";
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
		
		if(edited) {
			typing = 100;
			
			if(IS_PATREON) {
				shake_amount = PREFERENCES.textbox_shake;
				repeat(PREFERENCES.textbox_particle) spawn_particle(rx + cursor_pos, ry + cursor_pos_y + random(16), 8);
			}
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
		else if(auto_update && (edited || keyboard_check_pressed(vk_anykey)))
			apply();
	} #endregion
	
	static display_text = function(_x, _y, _text, _w, _m = -1) { #region
		draw_set_alpha(0.5 + 0.5 * interactable);
		_y += ui(1); //Huh?
		
		var cc = color;
		if(sliding == 2) cc = COLORS._main_accent
		
		draw_set_text(font, fa_left, fa_top, cc);
		draw_text_add(_x + disp_x, _y, _text + suffix);
		draw_set_alpha(1);
		
		_disp_text = _text;
		
		var _xx    = _x + disp_x;
		var _mm    = _m;
		var target = -999;
		
		if(!sliding && selecting) {
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
			
			if(target != -999) {
				if(!click_block) {
					if(mouse_press(mb_left, active)) {
						cursor_select = target;
						cursor		  = target;	
					} else if(mouse_click(mb_left, active) && cursor != target)
						cursor = target;
				}
			}
		
			if(mouse_release(mb_left, active))
				click_block	  = false;
				
		}
	} #endregion
	
	static drawParam = function(params) { #region
		setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m, params.halign, params.valign);
	} #endregion
	
	static draw = function(_x, _y, _w, _h, _text = "", _m = mouse_ui, halign = fa_left, valign = fa_top) { #region
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		hovering = false;
		if(shake_amount != 0) {
			_x += irandom_range(-shake_amount, shake_amount); 
			_y += irandom_range(-shake_amount, shake_amount); 
			if(shake_amount) shake_amount--;
		}
		
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
		
		var _bs = min(h, ui(32));
		
		if(_w - _bs > ui(100) && side_button) {
			side_button.setFocusHover(active, hover);
			side_button.draw(_x + _w - _bs, _y + _h / 2 - _bs / 2, _bs, _bs, _m, THEME.button_hide);
			_w -= _bs + ui(4);
		}
		
		var _raw_text = _text;
		_text         = string_real(_text);
		_current_text = _text;
		
		var tb_surf_x = _x + ui(8);
		var tb_surf_y = _y;
		
		var tx = _x;
		switch(align) {
			case fa_left   : tx = _x + ui(8);      break;
			case fa_center : tx = _x + _w / 2;     break;
			case fa_right  : tx = _x + _w - ui(8); break;
		}
		
		var _update = !surface_valid(text_surface, _w - ui(16), _h);
		if(_update) text_surface = surface_verify(text_surface, _w - ui(16), _h);
		
		if(!hide) {
			draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, _w, _h, boxColor, 1);
			
			if(slide_range != noone) {
				var _minn    = slide_range[0];
				var _maxx    = slide_range[1];
				var _rang    = abs(_maxx - _minn);
				var _currVal = toNumber(_current_text);
			
				if(sliding != 2) {
					curr_range[0] = (_currVal >= _minn)? _minn : _minn - ceil(abs(_currVal - _minn) / _rang) * _rang; 
					curr_range[1] = (_currVal <= _maxx)? _maxx : _maxx + ceil(abs(_currVal - _maxx) / _rang) * _rang;
				}
			
				var lw = _w * (_currVal - curr_range[0]) / (curr_range[1] - curr_range[0]);
				draw_sprite_stretched_ext(THEME.textbox, 4, _x, _y, lw, _h, boxColor, 1);
			}
		}
		
		if(_w > ui(48)) {
			if(sliding == 2) {
				var _ax0 = _x + ui(10);
				var _ax1 = _x + _w - ui(10);
				var _ay  = _y + _h / 2;
			
				draw_sprite_ui_uniform(THEME.arrow, 2, _ax0, _ay, 1, COLORS._main_accent, 1);
				draw_sprite_ui_uniform(THEME.arrow, 0, _ax1, _ay, 1, COLORS._main_accent, 1);
			
			} else if(label != "") {
				draw_set_text(font, fa_left, fa_center, COLORS._main_text_sub);
				
				draw_set_alpha(0.5);
				draw_text_add(_x + ui(8), _y + _h / 2, label);
				draw_set_alpha(1);
			}
		}
			
		disp_x = lerp_float(disp_x, disp_x_to, 5);
		
		var hoverRect = point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h);
		
		if(selecting) { 
			if(sprite_index == -1) draw_sprite_stretched_ext(THEME.textbox, 2, _x, _y, _w, _h, COLORS._main_accent, 1);
			else                   draw_sprite_stretched(THEME.textbox, sprite_index, _x, _y, _w, _h);
			
			editText();
			
			#region multiplier
				if(_w > ui(80) && input == TEXTBOX_INPUT.number) {
					draw_set_alpha(0.5);
				
					if(hover && point_in_rectangle(_m[0], _m[1], _x + _w - ui(32), _y, _x + _w, _y + _h)) {
						draw_set_alpha(1);
					
						if(mouse_press(mb_left, active)) {
							if(key_mod_press(ALT))	_input_text	= string_real(toNumber(_input_text) / 2);
							else					_input_text	= string_real(toNumber(_input_text) * 2);
							apply();
							
							if(IS_PATREON) shake_amount = PREFERENCES.textbox_shake;
						}
					}
					
					draw_set_text(f_p0b, fa_center, fa_center, COLORS._main_text_sub);
					if(key_mod_press(ALT)) draw_text_add(_x + _w - ui(16), _y + _h / 2, "/2");
					else                   draw_text_add(_x + _w - ui(16), _y + _h / 2, "x2");
					draw_set_alpha(1);
				}
			#endregion
			
			#region draw
				var txt = _input_text;
				draw_set_text(font, fa_left, fa_top);
				var tw = string_width(txt);
				var th = string_height(txt == ""? "l" : txt);
				
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
				
				cursor_pos_y = c_y0;
				cursor_pos   = cursor_pos == 0? cursor_pos_to : lerp_float(cursor_pos, cursor_pos_to, 2);
				
				if(cursor_select > -1) { //draw highlight
					draw_set_color(COLORS.widget_text_highlight);
					var c_x1 = tx + disp_x + string_width(string_copy(txt, 1, cursor_select));
					var _rx0 = clamp(min(cursor_pos, c_x1), tx, tx + _w);
					var _rx1 = clamp(max(cursor_pos, c_x1), tx, tx + _w);
					
					draw_roundrect_ext(_rx0, c_y0, _rx1, c_y1, THEME_VALUE.highlight_corner_radius, THEME_VALUE.highlight_corner_radius, 0);
				}
				
				var _mx = -1;
				var _my = -1;
				if(hover && hoverRect) {
					_mx = _m[0];
					_my = _m[1];
				}
				
				var _display_text = string_real(txt);
				if(_update || _display_text != _disp_text) {
					surface_set_shader(text_surface, noone, true, BLEND.add);
						display_text(tx - tb_surf_x, _h / 2 - th / 2, _display_text, _w - ui(4), _mx - tb_surf_x);
					surface_reset_shader();
				}
				
				BLEND_ALPHA
				draw_surface(text_surface, tb_surf_x, tb_surf_y);
				BLEND_NORMAL
				
				draw_set_color(COLORS._main_text_accent);
				draw_set_alpha(typing || current_time % (PREFERENCES.caret_blink * 2000) > PREFERENCES.caret_blink * 1000);
				draw_line_width(cursor_pos, c_y0, cursor_pos, c_y1, 2);
				draw_set_alpha(1);
				
				if(typing) typing--;
			#endregion
			
			disp_x_to = clamp(disp_x_to, disp_x_min, disp_x_max);
			
			if(!hoverRect && mouse_press(mb_left)) 
				deactivate();
				
		} else {
			draw_set_text(font, fa_left, fa_center);
			var _display_text = _raw_text;
			
			if(input == TEXTBOX_INPUT.number) {
				var dig       = floor(_w / string_width("0")) - 3;
				_display_text = string_real(_display_text, dig, precision);
			}
			
			var tw = string_width(_display_text);
			var th = string_height(_display_text);
				
			switch(align) {
				case fa_left   :				break;
				case fa_center : tx -= tw / 2;	break;
				case fa_right  : tx -= tw;		break;
			}
			
			if(hover && hoverRect) {
				hovering = true;
				draw_sprite_stretched_ext(THEME.textbox, 1, _x, _y, _w, _h, boxColor, 0.5 + (0.5 * interactable));	
					
				if(mouse_press(mb_left, active))
					activate();
				
				if(input == TEXTBOX_INPUT.number && key_mod_press(SHIFT)) {
					var amo = slide_speed;
					if(key_mod_press(CTRL)) amo *= 10;
					if(key_mod_press(ALT))  amo /= 10;
					
					if(mouse_wheel_down())	modifyValue(toNumber(_text) + amo * SCROLL_SPEED);
					if(mouse_wheel_up())	modifyValue(toNumber(_text) - amo * SCROLL_SPEED);
				}
				
				if(slidable && mouse_press(mb_left, active)) {
					sliding  = 1;
					slide_delta = 0;
					
					slide_mx = _m[0];
					slide_my = _m[1];
				} 
			
			} else if(!hide)
				draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _w, _h, boxColor, 0.5 + 0.5 * interactable);
			
			if(_update || _display_text != _disp_text) {
				surface_set_shader(text_surface, noone, true, BLEND.add);
					display_text(tx - tb_surf_x, _h / 2 - th / 2, _display_text, _w - ui(4));
				surface_reset_shader();
			}
			
			BLEND_ALPHA
			draw_surface(text_surface, tb_surf_x, tb_surf_y);
			BLEND_NORMAL
		}
		
		if(sliding > 0) { #region
			slide_delta += window_mouse_get_delta_x();
			slide_delta += window_mouse_get_delta_y();
			
			if(sliding == 1 && abs(slide_delta) > 8) {
				deactivate();
				textBox_slider.activate(toNumber(_input_text));
				sliding  = 2;
			}
			
			if(sliding == 2) {
				textBox_slider.tb = self;
				if(mouse_release(mb_left)) {
					deactivate();
					if(onRelease != noone) apply(onRelease);
				}
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