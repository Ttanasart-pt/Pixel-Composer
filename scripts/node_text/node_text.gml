#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Text", "Output Dimension > Toggle", "D", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[9].setValue((_n.inputs[9].getValue() + 1) % 2); });
	});
	
	FN_NODE_TOOL_INVOKE {
		hotkeyTool("Node_Text", "Edit Text", "T");
	});
#endregion

function Node_Text(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Text";
	font = f_p0;
	dimension_index = -1;
	
	newInput( 0, nodeValue_Text(         "Text",               self, "")).setVisible(true, true);
	
	////- Output
	
	newInput( 9, nodeValue_Enum_Scroll(  "Output Dimension",   self, 1, [ "Fixed", "Dynamic" ]));
	newInput( 6, nodeValue_Vec2(         "Fixed Dimension",    self, DEF_SURF )).setVisible(true, false);
	newInput(10, nodeValue_Padding(      "Padding",            self, [0, 0, 0, 0]));
	
	////- Alignment
	
	newInput(13, nodeValue_PathNode(     "Path",               self, noone)).setVisible(true, true);
	newInput(14, nodeValue_Float(        "Path Shift",         self, 0));
	newInput( 7, nodeValue_Enum_Button(  "H Align",            self, 0, array_create(3, THEME.inspector_text_halign)));
	newInput( 8, nodeValue_Enum_Button(  "V Align",            self, 0, array_create(3, THEME.inspector_text_valign)));
	newInput(27, nodeValue_Int(          "Max Line Width",     self, 0));
	newInput(30, nodeValue_Bool(         "Rotate Along Path",  self, true));
	
	////- Font
	
	newInput( 1, nodeValue_Font(         "Font",               self, "")).setVisible(true, false);
	newInput( 4, nodeValue_Vec2(         "Character Range",    self, [ 32, 128 ]));
	newInput( 2, nodeValue_Int(          "Size",               self, 16));
	newInput(15, nodeValue_Bool(         "Scale to Fit",       self, false));
	newInput( 3, nodeValue_Bool(         "Anti-aliasing ",     self, false));
	newInput(11, nodeValue_Float(        "Letter Spacing",     self, 0));
	newInput(12, nodeValue_Float(        "Line Height",        self, 0));
	
	////- Rendering
	
	newInput(28, nodeValue_Bool(         "Round Position",     self, true ));
	newInput( 5, nodeValue_Color(        "Color",              self, ca_white));
	newInput(29, nodeValue_Enum_Button(  "Blend Mode",         self, 1, [ "Normal", "Alpha" ]));
	
	////- Background
	
	newInput(16, nodeValue_Bool(         "Render Background",  self, false));
	newInput(17, nodeValue_Color(        "BG Color",           self, ca_black));
	
	////- Wave
	
	newInput(18, nodeValue_Bool(         "Wave",               self, false));
	newInput(22, nodeValue_Slider(       "Wave Shape",         self, 0, [ 0, 3, 0.01 ]));
	newInput(19, nodeValue_Float(        "Wave Amplitude",     self, 4));
	newInput(20, nodeValue_Float(        "Wave Scale",         self, 30));
	newInput(21, nodeValue_Rotation(     "Wave Phase",         self, 0));
	
	////- Trim
	
	newInput(23, nodeValue_Bool(         "Typewriter",         self, false));
	newInput(25, nodeValue_Enum_Button(  "Trim Type",          self, 0, [ "Character", "Word", "Line" ]));
	newInput(24, nodeValue_Slider_Range( "Range",              self, [ 0, 1 ]));
	newInput(26, nodeValue_Bool(         "Use Full Text Size", self, true ));
		
	// inputs 31
		
	input_display_list = [ 0, 
		["Output",		 true],	9,  6, 10,
		["Alignment",	false], 13, 14, 7, 8, 27, 30, 
		["Font",		false], 1,  2, 15, 3, 11, 12, 
		["Rendering",	false], 5, 
		["Background",   true, 16], 17, 
		["Wave",	     true, 18], 22, 19, 20, 21, 
		["Trim",		 true, 23], 25, 24, 26, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	 
	attribute_surface_depth();
	
	_font_current  = "";
	_size_current  = 0;
	_aa_current    = false;
	seed           = seed_random();
	draw_data      = [];
	draw_font_data = [];
	
	#region tool
		tools = [
			new NodeTool( "Edit Text", THEME.text_tools_edit ).setOnToggle(function() /*=>*/ { 
				KEYBOARD_STRING = ""; 
				var _currStr    = getSingleValue(0);
				edit_cursor     = 0;
				edit_cursor_sel = string_length(_currStr);
			}),
		];
		
		edit_cursor_hov = noone;
		edit_cursor     = noone;
		edit_cursor_sel = noone;
		edit_typing     = false;
	#endregion
	
	static generateFont = function(_path, _size, _aa) {
		if(PROJECT.animator.is_playing) return;
		if(font_exists(font) && _path == _font_current && _size == _size_current && _aa == _aa_current) return;
		
		_font_current = _path;
		_size_current = _size;
		_aa_current   = _aa;
		
		if(!file_exists_empty(_path)) return;
		
		if(font != f_p0 && font_exists(font)) font_delete(font);
		font_add_enable_aa(_aa);
		font = font_add(_path, _size, false, false, 0, 127);
	}
	
	static step = function() {
		var _font = getSingleValue(1);
		var _dimt = getSingleValue(9);
		var _path = getSingleValue(13);
		
		var _use_path = _path != noone && struct_has(_path, "getPointDistance");
		
		inputs[ 6].setVisible(_dimt == 0 || _use_path);
		inputs[ 7].setVisible(_dimt == 0 || _use_path);
		inputs[ 8].setVisible(_dimt == 0 || _use_path);
		inputs[ 9].setVisible(!_use_path);
		inputs[14].setVisible( _use_path);
		inputs[15].setVisible(_dimt == 0 && !_use_path && _font != "");
		
	}
	
	static waveGet = function(_ind) {
		var _x = __wave_phase + _ind * __wave_scale;
		
		var _sine = dsin(_x) * __wave_ampli;
		
		var _squr = sign(_sine) * __wave_ampli;
		    _squr = _squr != 0? _squr : __wave_ampli;
			
		var _taup = abs(_x + 90) % 360;
		var _tria = _taup > 180? 360 - _taup : _taup;
		    _tria = (_tria / 180 * 2 - 1) * __wave_ampli;
		
		     if(__wave_shape < 0) return _sine;
		else if(__wave_shape < 1) return lerp(_sine, _tria, frac(__wave_shape));
		else if(__wave_shape < 2) return lerp(_tria, _squr, frac(__wave_shape));
		else if(__wave_shape < 3) return abs(_x) % 360 > 360 * (0.5 - frac(__wave_shape) / 2)? -__wave_ampli : __wave_ampli;
		
		return random_range_seed(-1, 1, _x + seed) * __wave_ampli;
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		
		var _pth = getSingleValue(13);
		if(struct_has(_pth, "drawOverlay")) { var hv = _pth.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov = _hov || bool(hv); }
		
		if(isNotUsingTool()) return _hov;
		
		var _dat = array_safe_get(draw_data,      preview_index, 0);
		var _dft = array_safe_get(draw_font_data, preview_index, 0);
		if(_dat == 0) return _hov;
		
		var _cr_hover = noone;
		var _currStr  = getSingleValue(0);
		var _crx0 = 0, _cry0 = 0;
		var _crx1 = 0, _cry1 = 0;
		
		var _crmin = min(edit_cursor, edit_cursor_sel);
		var _crmax = max(edit_cursor, edit_cursor_sel);
		
		draw_set_text(_dft[0], _dft[1], _dft[2], _dft[3]);
		for( var i = 0, n = array_length(_dat); i < n; i++ ) {
			var _tdat = _dat[i];
			var _tx   = _tdat[0];
			var _ty   = _tdat[1];
			var _tchr = _tdat[2];
			var _tsw  = _tdat[3];
			var _tsh  = _tdat[4];
			var _trot = _tdat[5];
			
			var _tw = _tsw * string_width(_tchr);
			var _th = _tsh * string_height(_tchr);
			
			var _tbx0 = _x + _s * (_tx);
			var _tby0 = _y + _s * (_ty);
			var _tbx1 = _x + _s * (_tx + _tw);
			var _tby1 = _y + _s * (_ty + _th);
			
			var _tbxc = (_tbx0 + _tbx1) / 2;
			
		    if(hover && point_in_rectangle(_mx, _my, _tbx0, _tby0, _tbxc, _tby1)) {
		     	_cr_hover = i;
		     	draw_set_color(COLORS._main_icon); draw_set_alpha(.5); draw_line_width(_tbx0, _tby0, _tbx0, _tby1, 2); draw_set_alpha(1);
				
			} else if(hover && point_in_rectangle(_mx, _my, _tbxc, _tby0, _tbx1, _tby1)) {
				_cr_hover = i + 1;
				draw_set_color(COLORS._main_icon); draw_set_alpha(.5); draw_line_width(_tbx1, _tby0, _tbx1, _tby1, 2); draw_set_alpha(1);
				
			}
			
			if(edit_cursor_sel != noone && i >= _crmin && i < _crmax) {
				draw_set_color(COLORS.widget_text_highlight);
				draw_set_alpha(0.5);
				draw_rectangle(_tbx0, _tby0, _tbx1 - 1, _tby1 - 1, false);
				draw_set_alpha(1);
			}
			
			// draw cursor
			
			if(i == edit_cursor) {
				_crx0 = _tbx0;  _cry0 = _tby0;
				_crx1 = _tbx0;  _cry1 = _tby1;
				
			} else if(i + 1 == edit_cursor && i + 1 == n) {
				_crx0 = _tbx1; _cry0 = _tby0;
				_crx1 = _tbx1; _cry1 = _tby1;
			}
			
		}
		
		edit_cursor_hov = _cr_hover;
		var _out = getSingleValue(0, preview_index, true);
		draw_surface_ext_safe(_out, _x, _y, _s, _s);
		
		if(edit_cursor != noone) {
			draw_set_color(COLORS._main_text_accent);
			draw_set_alpha((edit_typing || current_time % (PREFERENCES.caret_blink * 2000) > PREFERENCES.caret_blink * 1000) * 0.75 + 0.25);
			draw_line_width(_crx0, _cry0, _crx1, _cry1, 2);
			draw_set_alpha(1);
		}
		
		if(isUsingTool("Edit Text")) {
			HOTKEY_BLOCK = true;
			
			if(mouse_press(mb_left, active)) {
				edit_cursor     = _cr_hover;
				edit_cursor_sel = noone;
				KEYBOARD_STRING = "";
				
			} else if(_cr_hover != noone && mouse_click(mb_left, active)) {
				if(_cr_hover != edit_cursor) edit_cursor_sel = _cr_hover;
			}
			
			if(keyboard_check_pressed(ord("A")) && key_mod_press(CTRL)) {
				edit_cursor     = 0;
				edit_cursor_sel = string_length(_currStr);
				
			} else if(edit_cursor != noone) {
				var _edit = false;
				
				if(KEYBOARD_PRESSED == vk_left) {
					edit_cursor = max(0, edit_cursor - 1);
					edit_cursor_sel = noone;
					
				} else if(KEYBOARD_PRESSED == vk_right) {
					edit_cursor = min(edit_cursor + 1, string_length(_currStr));
					edit_cursor_sel = noone;
					
				} else if(KEYBOARD_PRESSED == vk_escape) {
					PANEL_PREVIEW.tool_current = noone;
					edit_cursor_sel = noone;
					
				} else if(edit_cursor_sel != noone && (KEYBOARD_STRING != "" || KEYBOARD_PRESSED == vk_backspace || KEYBOARD_PRESSED == vk_delete)) {
					_currStr        = string_delete(_currStr, _crmin + 1, _crmax - _crmin);
					_edit           = true;
					edit_cursor     = _crmin;
					edit_cursor_sel = noone;
					
				} else if(KEYBOARD_PRESSED == vk_backspace) {
					_currStr    = string_delete(_currStr, edit_cursor, 1);
					_edit       = true;
					edit_cursor = max(0, edit_cursor - 1);
					
				} else if(KEYBOARD_PRESSED == vk_delete) {
					_currStr    = string_delete(_currStr, edit_cursor + 1, 1);
					_edit       = true;
				
				} else if(KEYBOARD_PRESSED == vk_enter) {
					_currStr    = string_insert("\n", _currStr, edit_cursor + 1);
					_edit       = true;
					
					edit_cursor    += 1;
					KEYBOARD_STRING = "";
					
				} else if(KEYBOARD_STRING != "") {
					_currStr    = string_insert(KEYBOARD_STRING, _currStr, edit_cursor + 1);
					_edit       = true;
					
					edit_cursor    += string_length(KEYBOARD_STRING);
					KEYBOARD_STRING = "";
				}
				
				if(_edit) inputs[0].setValue(_currStr);
			}
		}
		
		return _hov;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var str    = _data[ 0];
			var strRaw = str;
			
			var _dimt  = _data[ 9];
			var _dim   = _data[ 6];
			var _padd  = _data[10];
			
			var _path  = _data[13];
			var _pthS  = _data[14];
			var _hali  = _data[ 7];
			var _vali  = _data[ 8];
			var _lineW = _data[27];
			__pthR     = _data[30];
			
			var _font  = _data[ 1];
			var _size  = _data[ 2];
			var _scaF  = _data[15];
			var _aa    = _data[ 3];
			var _trck  = _data[11];
			var _line  = _data[12];
			
			__rnd_pos  = _data[28];
			var _col   = _data[ 5];
			var _bm    = _data[29];
			
			var _ubg   = _data[16];
			var _bgc   = _data[17];
			
			var _wave  = _data[18];
			var _waveH = _data[22];
			var _waveA = _data[19];
			var _waveS = _data[20];
			var _waveP = _data[21];
			
			var _type  = _data[23];
			var _typeC = _data[25];
			var _typeR = _data[24];
			var _typeF = _data[26];
		#endregion
			
		#region font
			__dwData   = array_create(string_length(str));
			__dwDataI  = 0;
			__f        = font;
			
			inputs[2].setVisible(false);
			inputs[3].setVisible(false);
				
			if(is_string(_font))   { 
				inputs[2].setVisible(_font != "");
				inputs[3].setVisible(_font != "");
			 	
			 	generateFont(_font, _size, _aa); 
			 	__f = font; 
				
			} else if(font_exists(_font)) { 
				__f = _font; 
			}
				
			draw_set_font(__f);
		#endregion
		
		#region typewritter
			if(_type) {
				var _typAmo = 0;
				var _typSpa = [];
				
				switch(_typeC) {
					case 0 : _typAmo = string_length(str); 
							 break;
							 
					case 1 : _typSpa = string_splice(str, [" ", "\n"], true);
							 _typAmo = array_length(_typSpa); 
							 break;
							 
					case 2 : _typSpa = string_splice(str, "\n", true);
					         _typAmo = array_length(_typSpa); 
							 break;
				}
				
				var _typS = round(_typeR[0] * _typAmo);
				var _typE = round(_typeR[1] * _typAmo);
				var _typStr = "";
				
				switch(_typeC) {
					case 0 : _typStr = string_copy(          str, _typS, _typE - _typS); break;
					case 1 : _typStr = string_concat_ext(_typSpa, _typS, _typE - _typS); break;
					case 2 : _typStr = string_concat_ext(_typSpa, _typS, _typE - _typS); break;
				}
				
				str = _typStr;
				if(_typeF == false) strRaw = str;
			}
		#endregion
		
		#region cut string
			var _cut_lines = string_splice(str, "\n");
			
			var _str_lines   = [];
			var _line_widths = [];
			var _ind = 0;
			
			for( var i = 0, n = array_length(_cut_lines); i < n; i++ ) {
				var _str_line = _cut_lines[i];
				
				if(_lineW == 0) {
					_str_lines[_ind]   = _str_line;
					_line_widths[_ind] = string_width(_str_line) + _trck * (string_length(_str_line) - 1);
					_ind++;
				} else {
					var _lw  = 0;
					var _lne = "";
					
					for( var j = 1; j <= string_length(_str_line); j++ ) {
						var _chr = string_char_at(_str_line, j);
						var _chw = string_width(_chr) + _trck;
						
						if(_lw + _chw >= _lineW) {
							_str_lines[_ind]   = _lne;
							_line_widths[_ind] = _lw - _trck;
							_ind++;
							
							_lne = "";
							_lw = 0;
						}
						
						_lne += _chr;
						_lw  += _chw;
					}
					
					if(_lne != "") {
						_str_lines[_ind]   = _lne;
						_line_widths[_ind] = _lw - _trck;
						_ind++;
					}
				}
			}
			
			var _max_ww = 0;
			var _max_hh = 0;
			
			for( var i = 0, n = array_length(_str_lines); i < n; i++ ) {
				_max_ww  = max(_max_ww, _line_widths[i]);
				_max_hh += string_height(_str_lines[i]);
				if(i) _max_hh += _line
			}
		#endregion
		
		#region dimension
			var ww = 0, _sw = 0;
			var hh = 0, _sh = 0;
		
			ww = _max_ww;
			hh = _max_hh;
		
			var _use_path = _path != noone && struct_has(_path, "getPointDistance");
			var _ss = 1;
		
			if(_use_path) {
				_sw = _dim[0];
				_sh = _dim[1];
				
			} else if (_dimt == 0) {
				_sw = _dim[0];
				_sh = _dim[1];
				if(_scaF) _ss = min(_sw / ww, _sh / hh);
				
			} else {
				_sw = ww;
				_sh = hh;
				if(_wave) _sh += abs(_waveA) * 2;
			}
			
			_sw += _padd[PADDING.left] + _padd[PADDING.right];
			_sh += _padd[PADDING.top] + _padd[PADDING.bottom];
			
			_outSurf = surface_verify(_outSurf, _sw, _sh, attrDepth());
		#endregion
		
		#region position
			var tx = 0, ty = _padd[PADDING.top], _ty = 0;
			if(_dimt == 0) {
				switch(_vali) {
					case 0 : ty = _padd[PADDING.top];						break;
					case 1 : ty = (_sh - hh * _ss) / 2;						break;
					case 2 : ty = _sh - _padd[PADDING.bottom] - hh * _ss;	break;
				}
			}
			
			if(_wave) ty += abs(_waveA);
		#endregion
		
		#region wave
			__wave       =  _wave;
			__wave_ampli =  _waveA;
			__wave_scale =  _waveS;
			__wave_phase = -_waveP;
			__wave_shape =  _waveH;
		#endregion
		
		surface_set_shader(_outSurf, noone, true, BLEND.alpha);
		if(_ubg) {
			draw_clear(_bgc);
			BLEND_ALPHA_MULP
		}
		
		__temp_pt   = _path;
		__temp_ss   = _ss;
		__temp_trck = _trck;
		
		if(_use_path) {
			var _pthl = _path.getLength(0), va;
			
			switch(_vali) {
				case 0 : va = fa_top;    ty = 0;                                    break;
				case 1 : va = fa_center; ty = (_max_hh - line_get_height(__f)) / 2; break;
				case 2 : va = fa_top;    ty =  _max_hh;                             break;
			}
			
			for( var i = 0, n = array_length(_str_lines); i < n; i++ ) {
				var _str_line   = _str_lines[i];
				var _line_width = _line_widths[i];
				draw_set_text(__f, fa_left, va, _col);
				draw_font_data[_array_index] = [__f, fa_left, va, _col];
				
				switch(_hali) {
					case 0 : tx = 0;                           break;
					case 1 : tx = _pthl / 2 - _line_width / 2; break;
					case 2 : tx = _pthl     - _line_width;     break;
				}
				
				__temp_tx = tx + _pthS;
				__temp_ty = ty;
				__temp_p0 = new __vec2P();
				__temp_p1 = new __vec2P();
				
				string_foreach(_str_line, function(_chr, _ind) /*=>*/ {
					var _p1  = __temp_pt.getPointDistance(__temp_tx,      0, __temp_p0);
					var _p2  = __temp_pt.getPointDistance(__temp_tx + .1, 0, __temp_p1);
					var _nor = __pthR? point_direction(_p1.x, _p1.y, _p2.x, _p2.y) : 0;
					
					var _line_ang = _nor + 90;
					var _dx = lengthdir_x(__temp_ty, _line_ang);
					var _dy = lengthdir_y(__temp_ty, _line_ang);
					
					var _tx = _p1.x + _dx;
					var _ty = _p1.y + _dy;
					
					if(__wave) {
						var _wd = waveGet(_ind);
						_tx += lengthdir_x(_wd, _line_ang + 90);
						_ty += lengthdir_y(_wd, _line_ang + 90);
					}
					
					if(__rnd_pos) { _tx = round(_tx); _ty = round(_ty); }
					
					draw_text_transformed(_tx, _ty, _chr, 1, 1, _nor);
					__dwData[__dwDataI++] = [_tx, _ty, _chr, 1, 1, _nor];
					
					__temp_tx += string_width(_chr) + __temp_trck;
				});
				
				ty -= string_height(_str_line) + _line;
			}
			
		} else {
			for( var i = 0, n = array_length(_str_lines); i < n; i++ ) {
				var _str_line   = _str_lines[i];
				var _line_width = _line_widths[i];
				draw_set_text(__f, fa_left, fa_top, _col);
				draw_font_data[_array_index] = [__f, fa_left, fa_top, _col];
				
				tx = _padd[PADDING.left];
				
				if(_dimt == 0) 
				switch(_hali) {
					case 0 : tx = _padd[PADDING.left];								break;
					case 1 : tx = (_sw - _line_width * _ss) / 2;					break;
					case 2 : tx = _sw - _padd[PADDING.right] - _line_width * _ss;	break;
				}
				
				__temp_tx = tx;
				__temp_ty = ty;
			
				string_foreach(_str_line, function(_chr, _ind) /*=>*/ {
					var _tx = __temp_tx;
					var _ty = __temp_ty;
					
					if(__wave) _ty += waveGet(_ind);
					if(__rnd_pos) { _tx = round(_tx); _ty = round(_ty); }
					
					draw_text_transformed(_tx, _ty, _chr, __temp_ss, __temp_ss, 0);
					__dwData[__dwDataI++] = [_tx, _ty, _chr, __temp_ss, __temp_ss, 0];
					
					__temp_tx += (string_width(_chr) + __temp_trck) * __temp_ss;
				});
			
				ty += (string_height(_str_line) + _line) * _ss;
			}
		}
		surface_reset_shader();
		
		array_resize(__dwData, __dwDataI);
		draw_data[_array_index] = __dwData;
		
		return _outSurf;
	}
}