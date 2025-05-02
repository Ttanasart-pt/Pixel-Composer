enum TEXT_AREA_FORMAT {
	_default,
	codeLUA,
	codeHLSL,
	delimiter,
	path_template,
	node_title,
}

function textArea(_input, _onModify) : textInput(_input, _onModify) constructor {
	hide     = false;
	color    = COLORS._main_text;
	boxColor = c_white;
	
	_input_text_line       = [];
	_input_text_line_index = [];
	
	_current_text	= "";
	_input_text		= "";
	_prev_text		= "";
	_last_value		= "";
	_prev_width		= 0;
	_stretch_width  = false;
	
	min_lines  = 0;
	line_width = 1000;
	max_height = -1;
	
	cursor			= 0;
	cursor_tx		= 0;
	cursor_pos_x	= 0;
	cursor_pos_x_to	= 0;
	cursor_pos_y	= 0;
	cursor_pos_y_to	= 0;
	cursor_line     = 0;
	
	char_run = 0
	
	cursor_select	= -1;
	
	click_block = 0;
	format = TEXT_AREA_FORMAT._default;
	
	code_line_width = 48;
	
	shift_new_line   = true;
	show_line_number = true;
	
	syntax_highlight = true;
	
	undoable   = true;
	undo_stack = ds_stack_create();
	redo_stack = ds_stack_create();
	
	text_surface   = noone;
	text_y         = 0;
	text_y_to      = 0;
	text_y_max     = 0;
	text_scrolling = false;
	text_scroll_sy = 0;
	text_scroll_my = 0;
	
	border_heightlight_color = COLORS._main_accent;
	
	_cl = -1;
	
	context_menu = [
		menuItem("Copy",  function() /*=>*/ { clipboard_set_text(_current_text); }, THEME.copy),
		menuItem("Paste", function() /*=>*/ { var _text = clipboard_get_text(); if(onModify) onModify(_text); }, THEME.paste),
	];
	
	context_menu_selecting = [
		menuItem("Copy",  function() /*=>*/ { 
			var minc = min(cursor, cursor_select);
			var maxc = max(cursor, cursor_select);
			clipboard_set_text(string_copy(_input_text, minc + 1, maxc - minc));
		}, THEME.copy),
		menuItem("Paste", function() /*=>*/ { var _text = clipboard_get_text(); if(onModify) onModify(_text); }, THEME.paste),
	];
	
	static setMaxHeight = function(h) { max_height = h; return self; }
	
	static activate = function() {
		WIDGET_CURRENT = self;
		WIDGET_CURRENT_SCROLL = parent;
		parentFocus();
		
		_input_text = _current_text;
		_last_value = _current_text;
		
		cursor_pos_x = 0;
		cursor_pos_y = 0;
		
		if(select_on_click) {
			cursor        = string_length(_current_text);
			cursor_select = 0;
			click_block   = 1;
		}
		
		KEYBOARD_STRING = "";
		keyboard_lastkey = -1;
					
		cut_line();
		
		ds_stack_clear(undo_stack);
		ds_stack_clear(redo_stack);
		ds_stack_push(undo_stack, [_input_text, cursor, cursor_select]);
				
		if(PEN_USE) keyboard_virtual_show(kbv_type_default, kbv_returnkey_default, kbv_autocapitalize_none, true);
	}
	
	static deactivate = function() { 
		if(WIDGET_CURRENT != self) return;
		
		apply();
		WIDGET_CURRENT = undefined;
		UNDO_HOLDING   = false;
		
		if(PEN_USE) keyboard_virtual_hide();
	}
	
	static isCodeFormat = function() { INLINE return format == TEXT_AREA_FORMAT.codeLUA || format == TEXT_AREA_FORMAT.codeHLSL; }
	
	static breakCharacter = function(ch) {
		if(isCodeFormat()) 
			return ch == "\n" || array_exists(global.CODE_BREAK_TOKEN, ch);	
		return ch == " " || ch == "\n";	
	}
	
	static onModified = function() {
		autocomplete_delay = 0;
		o_dialog_textbox_autocomplete.deactivate(self);
		o_dialog_textbox_function_guide.deactivate(self);
		
		if(autocomplete_server == noone) return;
		if(!use_autocomplete) return;
		
		var crop = string_copy(_input_text, 1, cursor);
		var slp  = string_splice(crop, [" ", "(", "[", "{", ",", "\n"]);
		var pmt  = array_safe_get(slp, -1,, ARRAY_OVERFLOW.loop);
		var _vars = [];
		
		if(parser_server != noone) {
			localParams = parser_server(crop, autocomplete_object);
			_vars = array_append(localParams, globalParams);
		}
		
		var data = autocomplete_server(pmt, _vars, autocomplete_context);
		
		o_dialog_textbox_autocomplete.data   = data;
		if(array_length(data)) {
			o_dialog_textbox_autocomplete.data   = data;
			o_dialog_textbox_autocomplete.prompt = pmt;
			autocomplete_modi = true;
		}
		
		if(function_guide_server == noone) return;
					
		var _c  = cursor;
		var _v  = false;
		var _fn = "";
		var _el = 0;
		var amo = 0;
		
		while(_c > 1) {
			var cch0 = string_char_at(_input_text, _c - 1);
			var cch1 = string_char_at(_input_text, _c);
						
			if(_el == 0 && cch1 == ",") amo++;
						
			if(_el == 0 && cch1 == "(" && string_variable_valid(cch0))
				_v = true;
			else if(cch1 == ")") _el++;
			else if(cch1 == "(") _el--;
						
			if(_v) {
				if(!string_variable_valid(cch0)) 
					break;
				_fn = cch0 + _fn;
			}
						
			_c--;
		}
		var guide = function_guide_server(_fn);
		
		if(guide != "") {
			o_dialog_textbox_function_guide.activate(self);
			o_dialog_textbox_function_guide.prompt   = guide;
			o_dialog_textbox_function_guide.index    = amo;
		}
	}
	
	static keyboardEnter = function() {
		if(!keyboard_check_pressed(vk_enter)) 
			return 0;
		
		if(use_autocomplete && o_dialog_textbox_autocomplete.active && o_dialog_textbox_autocomplete.textbox == self) 
			return 0;
		
		return 1 + ((shift_new_line && key_mod_press(SHIFT)) || (!shift_new_line && !key_mod_press(SHIFT)));
	}
	
	static onKey = function(key) {
		if(key == vk_left) {
			if(key_mod_press(SHIFT)) {
				if(cursor_select == -1)
					cursor_select = cursor;
			} else 
				cursor_select	= -1;
						
			move_cursor(-1);
			if(key_mod_press(CTRL)) {
				while(cursor > 0) {
					var ch = string_char_at(_input_text, cursor);
					if(breakCharacter(ch)) break;
					cursor--;
				}
			} 
		}
		if(key == vk_right) {
			if(key_mod_press(SHIFT)) {
				if(cursor_select == -1)
					cursor_select = cursor;
			} else 
				cursor_select	= -1;
					
			move_cursor(1);
			if(key_mod_press(CTRL)) {
				while(cursor < string_length(_input_text)) {
					var ch = string_char_at(_input_text, cursor);
					if(breakCharacter(ch)) break;
					cursor++;
				}
			} 
		}
		
		var tbActive = o_dialog_textbox_autocomplete.active && o_dialog_textbox_autocomplete.textbox == self;
		
		if(!(isCodeFormat() && tbActive)) {
			if(key == vk_up) {
				var _target;
				
				if(cursor_line == 0) 
					_target = 0;
				else {
					var _l = cursor_line - 1;
					var _str = _input_text_line[_l];
					var _run = cursor_tx;
					var _char = 0;
						
					for( var i = 0; i < _l; i++ )
						_char += string_length(_input_text_line[i]);
						
					for( var i = 1; i < string_length(_str); i++ ) {
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
				onModified();
			}
		
			if(key == vk_down) {
				var _target;
					
				if(cursor_line == array_length(_input_text_line) - 1) 
					_target = string_length(_input_text);
				else {
					var _l = cursor_line + 1;
					var _str = _input_text_line[_l];
					var _run = cursor_tx;
					var _char = 0;
						
					for( var i = 0; i < _l; i++ )
						_char += string_length(_input_text_line[i]);
						
					for( var i = 1; i < string_length(_str); i++ ) {
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
				onModified();
			}
		}
	}
	
	static apply = function() {
		if(onModify) onModify(_input_text);
		UNDO_HOLDING = true;
	}
	
	static move_cursor = function(delta) {
		var ll = string_length(_input_text);
		cursor = clamp(cursor + delta, 0, ll);
		
		onModified();
	}
	
	static cut_line = function() {
		_input_text_line = [];
		_input_text_line_index = [];
		draw_set_font(font);
		
		var _txtLines = string_splice(_input_text, "\n");
		var ss = "";
		var _code = isCodeFormat();
		
		for( var i = 0, n = array_length(_txtLines); i < n; i++ ) {
			var _txt  = _txtLines[i] + (i < array_length(_txtLines)? "\n" : "");
			var words;
			
			if(format == TEXT_AREA_FORMAT.codeLUA)
				words = lua_token_splice(_txt);
			else if(format == TEXT_AREA_FORMAT.codeHLSL)
				words = hlsl_token_splice(_txt);
			else
				words = string_splice(_txt, " ");
			
			var currW = 0;
			var currL = "";
			var cut = true;
			var len = array_length(words);
			var _iIndex = i + 1;
			
			for( var j = 0; j < len; j++ ) {
				var word = words[j];
				if(!_code && j < len - 1) word = word + " ";
				
				if(string_width(word) > line_width) { //the entire word is longer than a line
					for( var k = 1; k <= string_length(word); k++ ) {
						var ch = string_char_at(word, k);
						
						if(currW + string_width(ch) > line_width) {
							array_push(_input_text_line, currL);
							array_push(_input_text_line_index, _iIndex); _iIndex = "";
								
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
					array_push(_input_text_line_index, _iIndex); _iIndex = "";
								
					currW = 0;
					currL = "";
				}
				
				cut = true;
				currW += string_width(word);
				currL += word;
			}
			
			if(cut) {
				array_push(_input_text_line, currL);
				array_push(_input_text_line_index, _iIndex); _iIndex = "";	
			}
		}
	}
	
	static editText = function() {
		var _input_text_pre = _input_text;
		var modified = false;
		var undoing  = false;
		
		#region text editor
			if(key_mod_press(CTRL) && keyboard_check_pressed(ord("A"))) {
				cursor        = string_length(_input_text);
				cursor_select = 0;
				
			} else if(key_mod_press(CTRL) && !key_mod_press(SHIFT) && keyboard_check_pressed(ord("Z"))) {			// UNDO
				while(!ds_stack_empty(undo_stack) && _input_text == ds_stack_top(undo_stack)[0])
					ds_stack_pop(undo_stack);
				
				if(!ds_stack_empty(undo_stack)) {
					ds_stack_push(redo_stack, [_input_text, cursor, cursor_select]);
					var _pop = ds_stack_pop(undo_stack);
					_input_text   = _pop[0];
					cursor        = _pop[1];
					cursor_select = _pop[2];
					cut_line();
					
					undoing  = true;
					modified = true;
				}
			} else if(key_mod_press(CTRL) && key_mod_press(SHIFT) && keyboard_check_pressed(ord("Z"))) {			// REDO
				if(!ds_stack_empty(redo_stack)) {
					ds_stack_push(undo_stack, [_input_text, cursor, cursor_select]);
					var _pop = ds_stack_pop(redo_stack);
					_input_text   = _pop[0];
					cursor        = _pop[1];
					cursor_select = _pop[2];
					cut_line();
					
					undoing  = true;
					modified = true;
				}
			} else if(key_mod_press(CTRL) && (keyboard_check_pressed(ord("C")) || keyboard_check_pressed(ord("X")))) {
				if(cursor_select != -1) {
					var minc = min(cursor, cursor_select);
					var maxc = max(cursor, cursor_select);
					clipboard_set_text(string_copy(_input_text, minc + 1, maxc - minc));
				}
			} else {
				if(key_mod_press(CTRL) && keyboard_check_pressed(ord("V"))) {
					var _ctxt = clipboard_get_text();
					    _ctxt = string_replace_all(_ctxt, "\t", "    ");
					KEYBOARD_STRING = _ctxt;
				}
				
				if(keyboard_check_pressed(vk_escape)) {
				} else if(keyboard_check_pressed(vk_tab)) {
				} else if(keyboardEnter() == 2) {
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
					modified   = true;
					ds_stack_push(undo_stack, [_input_text, cursor, cursor_select]);
					
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
						
						_input_text = str_before + str_after;
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
					
					cursor_select = -1;
					move_cursor(-1);
					modified = true;
					
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
						_input_text	= str_before + str_after;
						cut_line();
					}
					
					cursor_select = -1;
					modified = true;
					
				} else if(KEYBOARD_STRING != "" && KEYBOARD_STRING != "\b" && KEYBOARD_STRING != "\r") {
					var ch = KEYBOARD_STRING;
					
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
					
					if(string_pos(" ", ch)) ds_stack_push(undo_stack, [_input_text, cursor, cursor_select]);
					cursor_select = -1;
					modified      = true;
				}
			}
			
			KEYBOARD_STRING = "";
			keyboard_lastkey = -1;
		#endregion
		
		if(modified) {
			undoable = !undoing;
			typing   = 100;
			
			onModified();
			
			if(IS_PATREON) {
				shake_amount = PREFERENCES.textbox_shake;
				repeat(PREFERENCES.textbox_particle) spawn_particle(rx + cursor_pos_x, ry + cursor_pos_y + random(16), 8);
			}
		}
		
		if(auto_update && (keyboard_check_pressed(vk_anykey) || modified))
			apply();
			
		if(KEYBOARD_PRESSED == vk_left)  onKey(vk_left);
		if(KEYBOARD_PRESSED == vk_right) onKey(vk_right);
		if(KEYBOARD_PRESSED == vk_up)    onKey(vk_up);
		if(KEYBOARD_PRESSED == vk_down)  onKey(vk_down);
		
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
			
			autocomplete_delay = 0;
			o_dialog_textbox_autocomplete.deactivate(self);
			o_dialog_textbox_function_guide.deactivate(self);
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
			
			autocomplete_delay = 0;
			o_dialog_textbox_autocomplete.deactivate(self);
			o_dialog_textbox_function_guide.deactivate(self);
		} else if(keyboard_check_pressed(vk_escape) && o_dialog_textbox_autocomplete.textbox != self) {
			_input_text = _last_value;
			cut_line();
			deactivate();
		} else if(keyboardEnter() == 1) {
			deactivate();
		}
	}
	
	static display_text = function(_x, _y, _text, _mx = -1, _my = -1, _hover = false) {
		_text = string_real(_text);
		if(line_width != _prev_width) {
			_prev_width = line_width;
			cut_line();
		}
		
		draw_set_text(font, fa_left, fa_top, color);
		draw_set_alpha(0.5 + 0.5 * interactable);
		_y += ui(1);
		
		var ch_x = _x;
		var ch_y = _y;
		var _str;
		
		text_y_max = 0;
		
		if(_input_text != _text) {
			_input_text = _text;
			cut_line();
		}
		
		__code_draw_comment = false;
		
		for( var i = 0, n = array_length(_input_text_line); i < n; i++ ) {
			_str = _input_text_line[i];
			
			if(_input_text_line_index[i] != "") {
				draw_set_color(color);
				__code_draw_comment = false;
			}
			
			switch(format) {
				case TEXT_AREA_FORMAT._default : 
					draw_text_add(ch_x, ch_y, _str);
					break;
					
				case TEXT_AREA_FORMAT.delimiter :
					draw_text_delimiter(ch_x, ch_y, _str);
					break;
					
				case TEXT_AREA_FORMAT.path_template : 
					draw_text_path(ch_x, ch_y, _str);
					break;
					
				case TEXT_AREA_FORMAT.codeLUA :
					if(syntax_highlight) draw_code_lua(ch_x, ch_y, _str);
					else                 draw_text_add(ch_x, ch_y, _str);
					break;
					
				case TEXT_AREA_FORMAT.codeHLSL :
					if(syntax_highlight) draw_code_hlsl(ch_x, ch_y, _str);
					else                 draw_text_add(ch_x, ch_y, _str);
					break;
			}
			
			ch_y       += line_get_height();
			text_y_max += line_get_height();
		}
		
		draw_set_alpha(1);
		
		var target = undefined;
		
		if(_hover) {
			target = 0;
			var char_run = 0, _l, _ch_w, _ch_h, _str, _chr;
			var sx     = _x;
			var ch_x   = sx;
			var ch_cxo = sx;
			var ch_cxn = sx;
			var ch_y   = _y;
			var _found_char = false;
					
			for( var i = 0, n = array_length(_input_text_line); i < n; i++ ) {
				_str = string_trim_end(_input_text_line[i]);
				_l   = string_length(_str);
				_ch_h  = line_get_height();
				ch_cxo = sx;
				ch_x   = sx;
				
				if((i == 0 || ch_y <= _my) && (i == n - 1 || _my < ch_y + _ch_h)) {
					for( var j = 0; j < _l; j++ ) {
						_chr = string_char_at(_str, j + 1);
						_ch_w = string_width(_chr);
						ch_cxn = ch_x + _ch_w / 2;
						
						if(_mx <= ch_cxn) {
							target = char_run + j;
							_found_char = true;
							break;
						}
						
						ch_x  += _ch_w;
						ch_cxo = ch_cxn;
					}
					
					if(!_found_char) target = char_run + _l;
					_found_char = true;
					break;
				}
				
				char_run += string_length(_input_text_line[i]);	
				ch_y += _ch_h;
			}
			
			if(ch_y <= _my && !_found_char) target = char_run - 1;
			
			if(mouse_press(mb_right, active))
				menuCall("textbox_context", context_menu_selecting);
		}
		
		if(target != undefined && !click_block) {
			if(mouse_press(mb_left, active) && HOVER != o_dialog_textbox_autocomplete.id) {
				cursor_select = target;
				cursor		  = target;
				
				o_dialog_textbox_autocomplete.deactivate(self);
				
			} else if(mouse_click(mb_left, active)) {
				cursor = target;
			}
		}
		
		if(mouse_release(mb_left)) {
			click_block	  = false;
			
			if(cursor_select == cursor)
				cursor_select = -1;
		}
		
	}
	
	static drawParam = function(params) {
		setParam(params);
		
		if(format == TEXT_AREA_FORMAT.codeHLSL || format == TEXT_AREA_FORMAT.codeLUA) 
			font = f_code;
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _text, _m) {
		_h = max_height == -1? _h : min(_h, max_height);
		
		////- Dimension
		
		x = _x; y = _y;
		w = _w; h = _h;
		
		hovering = false;
		
		autocomplete_delay += delta_time / 1000;
		_stretch_width      = _w < 0;
		_text               = string_real(_text);
		_current_text       = _text;
		
		draw_set_font(font);
		if(_stretch_width) _w = string_width(self == WIDGET_CURRENT? _input_text : _text) + ui(16);
		
		w  = _w;
		var _bs = min(h, ui(32));
		
		if(_w - _bs > ui(100) && side_button && instanceof(side_button) == "buttonClass") {
			side_button.setFocusHover(active, hover);
			side_button.draw(_x + _w - _bs, _y + _h / 2 - _bs / 2, _bs, _bs, _m, THEME.button_hide_fill);
			_w -= _bs + ui(8);
		}
		
		var tx = ui(8);
		var hh = _h;
		var pl = line_width;
		
		if(format == TEXT_AREA_FORMAT._default) {
			line_width = _w - ui(16);
			
		} else if(isCodeFormat()) {
			line_width = _w - ui(16 + code_line_width * show_line_number);
			tx += ui(code_line_width * show_line_number);
		}
		
		if(_stretch_width) line_width = 9999999;
		cursor_tx = _x + tx;
		
		var c_h        = line_get_height();
		var line_count = max(min_lines, array_length(_input_text_line));
		
		hh = max(_h, ui(14) + c_h * line_count);
		if(max_height) hh = min(hh, max_height);
		
		var _hw = _w;
		if(max_height && text_y_max) {
			_hw        -= 16;
			line_width -= 16;
		}
		
		////- Draw
		
		var hoverRect = point_in_rectangle(_m[0], _m[1], _x, _y, _x + _hw, _y + hh);
		var tsw       = _w;
		var tsh       = hh;
		var _update   = !surface_valid(text_surface, tsw, tsh);
		if(_update) text_surface = surface_verify(text_surface, tsw, tsh);
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, _w, hh, boxColor, 1);
		
		surface_set_shader(text_surface, noone, true, BLEND.add);
			if(isCodeFormat() && show_line_number) {
				draw_sprite_stretched_ext(THEME.textbox_code, 0, 0, 0, ui(code_line_width), hh, boxColor, 1);
				draw_set_text(f_code, fa_right, fa_top, COLORS._main_text_sub);
			
				var lx = ui(code_line_width - 8);
				
				for( var i = 0; i < array_length(_input_text_line_index); i++ ) {
					var ly = text_y + ui(7) + i * c_h;
					draw_text_add(lx, ly, _input_text_line_index[i]);
				}
			}
		surface_reset_shader();
		
		////- Selecting
		
		if(selecting) { 
			WIDGET_TAB_BLOCK = true;
			
			draw_set_text(font, fa_left, fa_top, COLORS._main_text);
			editText();
			
			if(!typing && undoable && (ds_stack_empty(undo_stack) || ds_stack_top(undo_stack)[0] != _input_text)) {
				ds_stack_push(undo_stack, [_input_text, cursor, cursor_select]);
				ds_stack_clear(redo_stack);
			}
			
			var msx = _m[0] - _x;
			var msy = _m[1] - _y;
			
			surface_set_shader(text_surface, noone, false, BLEND.add);
				draw_set_text(font, fa_left, fa_top, COLORS._main_text);
			
				#region draw cursor highlight
					var _l, _str;
				
					var ch_x       = tx;
					var ch_y       = text_y + ui(7);
					var ch_sel_min = -1;
					var ch_sel_max = -1;
					var char_line  = 0;
					var curs_found = false;
				
					char_run = 0;
				
					if(cursor_select != -1) {
						ch_sel_min = min(cursor_select, cursor);
						ch_sel_max = max(cursor_select, cursor);
					}
				
					for( var i = 0, n = array_length(_input_text_line); i < n; i++ ) {
						_str = _input_text_line[i];
						_l = string_length(_str);
					
						if(cursor_select != -1) {
							draw_set_color(COLORS.widget_text_highlight);
						
							if(char_line <= ch_sel_min && char_line + _l > ch_sel_min) {
								var _hstr1 = string_copy(_str, 1, ch_sel_min - char_line);
								var _hstr2 = string_copy(_str, 1, ch_sel_max - char_line);
							
								if(format == TEXT_AREA_FORMAT.delimiter) {
									_hstr1 = string_replace_all(_hstr1, " ", "<space>");
									_hstr2 = string_replace_all(_hstr2, " ", "<space>");
								}
							
								var x1 = tx + string_width(_hstr1);
								var x2 = tx + string_width(_hstr2);
							
								draw_roundrect_ext(x1, ch_y, x2, ch_y + c_h, THEME_VALUE.highlight_corner_radius, THEME_VALUE.highlight_corner_radius, 0);
							} else if(char_line >= ch_sel_min && char_line + _l < ch_sel_max) {
								var _hstr = _str;
							
								if(format == TEXT_AREA_FORMAT.delimiter)
									_hstr = string_replace_all(_hstr, " ", "<space>");
								
								var x2 = tx + string_width(_hstr);
							
								draw_roundrect_ext(tx, ch_y, x2, ch_y + c_h, THEME_VALUE.highlight_corner_radius, THEME_VALUE.highlight_corner_radius, 0);
							} else if(char_line > ch_sel_min && char_line <= ch_sel_max && char_line + _l >= ch_sel_max) {
								var _hstr = string_copy(_str, 1, ch_sel_max - char_line);
							
								if(format == TEXT_AREA_FORMAT.delimiter)
									_hstr = string_replace_all(_hstr, " ", "<space>");
								
								var x2 = tx + string_width(_hstr);
							
								draw_roundrect_ext(tx, ch_y, x2, ch_y + c_h, THEME_VALUE.highlight_corner_radius, THEME_VALUE.highlight_corner_radius, 0);
							}
						}
					
						if(!curs_found && char_line <= cursor && cursor < char_line + _l) {
							if(format == TEXT_AREA_FORMAT.delimiter) {
								var str_cur = string_copy(_str, 1, cursor - char_line);
								str_cur = string_replace_all(str_cur, " ", "<space>");
								cursor_pos_x_to = ch_x + string_width(str_cur);
							} else 
								cursor_pos_x_to = ch_x + string_width(string_copy(_str, 1, cursor - char_line));
							cursor_pos_y_to = ch_y;
							cursor_line = i;
							char_run    = char_line;
						
							curs_found = true;
						}
					
						char_line += _l;
						ch_y += line_get_height();
					}
				
					cursor_pos_x = cursor_pos_x == 0? cursor_pos_x_to : lerp_float(cursor_pos_x, cursor_pos_x_to, 1);
					cursor_pos_y = cursor_pos_y == 0? cursor_pos_y_to : lerp_float(cursor_pos_y, cursor_pos_y_to, 1);
				#endregion
				
				display_text(tx, text_y + ui(7), _input_text, msx, msy, hover && hoverRect);
				
				if(cursor_pos_y != 0 && cursor_pos_x != 0) {
					draw_set_color(COLORS._main_text_accent);
					draw_set_alpha((typing || current_time % (PREFERENCES.caret_blink * 2000) > PREFERENCES.caret_blink * 1000) * 0.8 + 0.2);
					draw_line_width(cursor_pos_x, cursor_pos_y, cursor_pos_x, cursor_pos_y + c_h, 2);
					draw_set_alpha(1);
				}
				
			surface_reset_shader();
		
			BLEND_ALPHA
				draw_surface(text_surface, _x, _y);
			BLEND_NORMAL
			
			if(typing) typing--;
			
			draw_sprite_stretched_ext(THEME.textbox, 2, _x, _y, _w, hh, border_heightlight_color, 1);
			
			if(o_dialog_textbox_autocomplete.textbox == self) {
				o_dialog_textbox_autocomplete.dialog_x = rx + _x + cursor_pos_x + 1;
				o_dialog_textbox_autocomplete.dialog_y = ry + _y + cursor_pos_y + line_get_height() + 1;
			}
			
			if(o_dialog_textbox_function_guide.textbox == self) {
				o_dialog_textbox_function_guide.dialog_x = rx + _x + cursor_pos_x + 1;
				o_dialog_textbox_function_guide.dialog_y = ry + _y + cursor_pos_y - 12;
			}
			
			if(autocomplete_modi && PREFERENCES.widget_autocomplete_delay >= 0 && autocomplete_delay >= PREFERENCES.widget_autocomplete_delay) {
				o_dialog_textbox_autocomplete.activate(self);
				autocomplete_modi = false;
			}
				
			if(!point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + hh) && mouse_press(mb_left) && HOVER != o_dialog_textbox_autocomplete.id)
				deactivate();
				
		} else {
			surface_set_shader(text_surface, noone, false, BLEND.add);
				display_text(tx, text_y + ui(7), _text);
			surface_reset_shader();
			
			BLEND_ALPHA
				draw_surface(text_surface, _x, _y);
			BLEND_NORMAL
			
			if(hover && hoverRect) {
				hovering = true;
				
				draw_sprite_stretched_ext(THEME.textbox, 1, _x, _y, _w, hh, boxColor, 0.5 + 0.5 * (interactable && !hide));
				
				if(mouse_press(mb_left, active))
					activate();
				
				if(mouse_press(mb_right, active))
					menuCall("textbox_context", context_menu);
					
			} else if(!hide)
				draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _w, hh, boxColor, 0.5 + 0.5 * interactable);
				
			o_dialog_textbox_autocomplete.deactivate(self);
		}
		
		////- Text height
		
		if(max_height) { 
			var total_h = text_y_max;
			text_y_max  = max(0, total_h - hh + 16);
			text_y      = lerp_float(text_y, text_y_to, 5);
		
			if(ihover && MOUSE_WHEEL != 0) text_y_to = clamp(text_y_to + ui(64) * MOUSE_WHEEL, -text_y_max, 0);
			
			var scr_w = ui(sprite_get_width(THEME.ui_scrollbar));
			var scr_h = hh - (ui(12) - scr_w) * 2;
			var scr_x = _x + _w - ui(12);
			var scr_y = _y + ui(12) - scr_w;
				
			var bar_h = hh / total_h * scr_h;
			var bar_y = scr_y + (scr_h - bar_h) * abs(text_y / text_y_max);
				
			if(text_scrolling) {
				text_y_to = text_scroll_sy - (_m[1] - text_scroll_my) / bar_h * scr_h;
				text_y_to = clamp(text_y_to, -text_y_max, 0);
				
				if(mouse_release(mb_left))
					text_scrolling = false;
			}
			
			if(text_y_max) {
				var hov = ihover && point_in_rectangle(_m[0], _m[1], scr_x - 3, _y, _x + _w, _y + _h);
				
				draw_sprite_stretched_ext(THEME.ui_scrollbar, 0, scr_x, scr_y, scr_w, scr_h, COLORS.scrollbar_bg,   1);
				draw_sprite_stretched_ext(THEME.ui_scrollbar, 0, scr_x, bar_y, scr_w, bar_h, hov || text_scrolling? COLORS.scrollbar_hover : COLORS.scrollbar_idle, 1);
				
				if(hov && mouse_press(mb_left, iactive)) {
					text_scrolling = true;
					text_scroll_sy = text_y;
					text_scroll_my = _m[1];
				}
			}
		}
		
		////- Dragging
		
		if(DRAGGING && (DRAGGING.type == "Text" || DRAGGING.type == "Number") && hover && hoverRect) {
			draw_sprite_stretched_ext(THEME.ui_panel, 1, _x, _y, _w, hh, COLORS._main_value_positive, 1);
			if(mouse_release(mb_left))
				onModify(DRAGGING.data);
		}
		
		selecting      = self == WIDGET_CURRENT;
		shift_new_line = true;
		resetFocus();
		
		return hh;
	}
	
	static clone = function() { return new textArea(input, onModify); }
	static free  = function() { surface_free_safe(text_surface); }
}