#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Text", "Output Dimension > Toggle", "D", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[9].setValue((_n.inputs[9].getValue() + 1) % 2); });
	});
	
	FN_NODE_TOOL_INVOKE {
		hotkeyCustom("Node_Text", "Edit Text", "T");
	});
#endregion

function Node_Text(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Text";
	dimension_index = -1;
	
	////- =Text
	newInput( 0, nodeValue_Text(         "Text" )).setVisible(true, true);
	newInput(32, nodeValue_Enum_Scroll(  "Change Case", 0, [ "None", "Lowercase", "Uppercase", "Titlecase" ] ));
	
	////- =Output
	newInput( 9, nodeValue_Enum_Scroll(  "Output Dimension", 1, [ "Fixed", "Dynamic" ]));
	newInput( 6, nodeValue_Vec2(         "Fixed Dimension",  DEF_SURF  )).setVisible(true, false);
	newInput(34, nodeValue_Vec2(         "Offset",           [0,0]     ));
	newInput(10, nodeValue_Padding(      "Padding",          [0,0,0,0] ));
	newInput(33, nodeValue_Bool(         "Atlas",            false     ));
	
	////- =Alignment
	newInput(13, nodeValue_PathNode(     "Path"));
	newInput(14, nodeValue_Float(        "Path Shift",        0    ));
	newInput(27, nodeValue_Int(          "Max Line Width",    0    ));
	newInput( 7, nodeValue_Enum_Button(  "H Align",           0, array_create(3, THEME.inspector_text_halign) ));
	newInput( 8, nodeValue_Enum_Button(  "V Align",           0, array_create(3, THEME.inspector_text_valign) ));
	newInput(30, nodeValue_Bool(         "Rotate Along Path", true ));
	
	////- =Font
	newInput( 1, nodeValue_Font()).setVisible(true, false);
	newInput( 4, nodeValue_Vec2(         "Character Range", [32,128] ));
	newInput( 2, nodeValue_Int(          "Size",             16      ));
	newInput(15, nodeValue_Bool(         "Scale to Fit",     false   ));
	newInput( 3, nodeValue_Bool(         "Anti-aliasing ",   false   ));
	newInput(11, nodeValue_Float(        "Letter Spacing",   0       ));
	newInput(12, nodeValue_Float(        "Line Height",      0       ));
	
	////- =Rendering
	newInput(28, nodeValue_Bool(         "Round Position",   true     ));
	newInput( 5, nodeValue_Color(        "Color",            ca_white ));
	newInput(29, nodeValue_Enum_Button(  "Blend Mode",       1, [ "Normal", "Alpha" ] ));
	newInput(31, nodeValue_Palette(      "Color by Letter", [ca_white] )).setOptions("Select by:", "array_select", [ "Index Loop", "Index Ping-pong", "Random" ], THEME.array_select_type).iconPad();
	
	////- =Background
	newInput(16, nodeValue_Bool(         "Render Background", false    ));
	newInput(17, nodeValue_Color(        "BG Color",          ca_black ));
	
	////- =Wave
	newInput(18, nodeValue_Bool(         "Wave",           false ));
	newInput(22, nodeValue_Slider(       "Wave Shape",     0, [ 0, 3, 0.01 ]));
	newInput(19, nodeValue_Float(        "Wave Amplitude", 4     ));
	newInput(20, nodeValue_Float(        "Wave Scale",     30    ));
	newInput(21, nodeValue_Rotation(     "Wave Phase",     0     ));
	
	////- =Trim
	newInput(23, nodeValue_Bool(         "Trim",               false ));
	newInput(25, nodeValue_Enum_Button(  "Trim Type",          0, [ "Character", "Word", "Line" ] ));
	newInput(24, nodeValue_Slider_Range( "Range",             [0,1]  ));
	newInput(26, nodeValue_Bool(         "Use Full Text Size", false ));
		
	// inputs 35
		
	input_display_list = [ 
		["Text",	    false    ],  0, 32, 
		["Output",		 true    ],	 9,  6, 34, 10, 33, 
		["Alignment",	false    ], 13, 14, 27,  7,  8, 30, 
		["Font",		false    ],  1,  2, 15,  3, 11, 12, 
		["Rendering",	false    ],  5, 31, 
		["Background",   true, 16], 17, 
		["Wave",	     true, 18], 22, 19, 20, 21, 
		["Trim",		 true, 23], 25, 24, 26, 
	];
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output( "Draw Data",   VALUE_TYPE.atlas,   []    )).setArrayDepth(1);
	 
	attribute_surface_depth();
	
	font = f_p0;
	_font_current  = "";
	_size_current  = 0;
	_aa_current    = false;
	
	seed           = seed_random();
	draw_data      = [];
	draw_font_data = [];
	
	#region tool
		tools = [
			new NodeTool( "Edit Text", THEME.text_tools_edit ).setOnToggle(function() /*=>*/ { 
				KEYBOARD_RESET
				var _currStr    = getInputSingle(0);
				edit_cursor     = 0;
				edit_cursor_sel = string_length(_currStr);
			}),
		];
		
		edit_cursor_hov = noone;
		edit_cursor     = noone;
		edit_cursor_sel = noone;
		edit_typing     = false;
	#endregion
	
	////- Nodes
	
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
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _hov = false;
		
		InputDrawOverlay(inputs[13].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params));
		InputDrawOverlay(inputs[34].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		if(isNotUsingTool()) return _hov;
		
		var _dat = array_safe_get(draw_data,      preview_index, 0);
		var _dft = array_safe_get(draw_font_data, preview_index, 0);
		if(_dat == 0) return _hov;
		
		var _cr_hover = noone;
		var _currStr  = getInputSingle(0);
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
		var _out = getInputSingle(0, preview_index, true);
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
				KEYBOARD_RESET
				
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
					
				} else if(edit_cursor_sel != noone && (KEYBOARD_PRESSED_STRING != "" || KEYBOARD_PRESSED == vk_backspace || KEYBOARD_PRESSED == vk_delete)) {
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
					KEYBOARD_RESET
					
				} else if(KEYBOARD_PRESSED_STRING != "") {
					_currStr    = string_insert(KEYBOARD_PRESSED_STRING, _currStr, edit_cursor + 1);
					_edit       = true;
					
					edit_cursor    += string_length(KEYBOARD_PRESSED_STRING);
					KEYBOARD_RESET
				}
				
				if(_edit) inputs[0].setValue(_currStr);
			}
		}
		
		return _hov;
	}
	
	static processData = function(_outData, _data, _array_index) {
		#region data
			var str    = _data[ 0]; 
			var _case  = _data[32];
			
			var _dimt  = _data[ 9];
			var _dim   = _data[ 6];
			var _off   = _data[34];
			var _padd  = _data[10];
			var _atls  = _data[33];
			
			var _path  = _data[13];
			var _pthS  = _data[14];
			var _lineW = _data[27];
			var _hali  = _data[ 7];
			var _vali  = _data[ 8];
			__pthR     = _data[30];
			
			var _font  = _data[ 1];
			var _size  = _data[ 2];
			var _scaF  = _data[15];
			var _aa    = _data[ 3];
			var _trck  = _data[11];
			var _line  = _data[12];
			
			var _col   = _data[ 5];
			var _colLt = _data[31];
			
			var _ubg   = _data[16];
			var _bgc   = _data[17];
			
			var _wave  = _data[18];
			var _waveH = _data[22];
			var _waveA = _data[19];
			var _waveS = _data[20];
			var _waveP = _data[21];
			
			var _type  = _data[23];
			var _trimC = _data[25];
			var _trimR = _data[24];
			var _trimF = _data[26];
			
			var _use_path = _path != noone && struct_has(_path, "getPointDistance");
			
			inputs[ 6].setVisible(_dimt == 0 || _lineW > 0 || _use_path);
			inputs[34].setVisible(_dimt == 0 || _lineW > 0 || _use_path);
			inputs[ 9].setVisible(!_use_path);
			inputs[14].setVisible( _use_path);
			inputs[15].setVisible(_dimt == 0 && !_use_path && _font != "");
			
			outputs[1].setVisible(_atls);
		#endregion
			
		#region modify text
			switch(_case) {
		        case 1 : str = string_lower(str);     break;
		        case 2 : str = string_upper(str);     break;
		        case 3 : str = string_titlecase(str); break;
		    }
		    
			var rawStr = str;
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
		
		#region trim
			if(_type) {
				var _typAmo = 0;
				var _typSpa = [];
				
				switch(_trimC) {
					case 0 : _typAmo = string_length(str); 
							 break;
							 
					case 1 : _typSpa = string_splice(str, [" ", "\n"], true);
							 _typAmo = array_length(_typSpa); 
							 break;
							 
					case 2 : _typSpa = string_splice(str, "\n", true);
					         _typAmo = array_length(_typSpa); 
							 break;
				}
				
				var _typS = round(_trimR[0] * _typAmo);
				var _typE = round(_trimR[1] * _typAmo);
				var _typStr = "";
				
				switch(_trimC) {
					case 0 : _typStr = string_copy(          str, _typS+1, _typE - _typS); break;
					case 1 : _typStr = string_concat_ext(_typSpa, _typS,   _typE - _typS); break;
					case 2 : _typStr = string_concat_ext(_typSpa, _typS,   _typE - _typS); break;
				}
				
				str = _typStr;
			}
		#endregion
		
		#region cut lines
			var _cut_lines   = string_splice(str, "\n");
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
			
			if(_trimF == false) {
				for( var i = 0, n = array_length(_str_lines); i < n; i++ ) {
					_max_ww  = max(_max_ww, _line_widths[i]);
					_max_hh += string_height(_str_lines[i]);
					if(i) _max_hh += _line;
				}
			} else {
				if(_lineW == 0) {
					_max_ww = string_width(  rawStr );
					_max_hh = string_height( rawStr );
					
				} else {
					_max_ww = string_width_ext(  rawStr, -1, _lineW );
					_max_hh = string_height_ext( rawStr, -1, _lineW );
				}
			}
		#endregion
		
		#region dimension
			var ww = _max_ww;
			var hh = _max_hh;
			
			var _sw = 0;
			var _sh = 0;
			
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
			
			_outSurf = _outData[0];
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
		
		__col       = _col;
		__colLt     = _colLt;
		__colLtTyp  = inputs[31].attributes.array_select;
		__colLtLen  = array_length(_colLt);
		__outAtlas  = _atls;
		__atlas     = [];
		
		__offx      = _off[0];
		__offy      = _off[1];
		
		if(_use_path) {
			var _pthl = _path.getLength(0);
			
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
					
					var clti = __dwDataI;
					switch(__colLtTyp) {
						case 0  : clti = __dwDataI % __colLtLen;                break;
						case 1  : clti = pingpong_value(__dwDataI, __colLtLen); break;
						case 2  : clti = irandom(__colLtLen - 1);               break;
					}
					
					_tx += __offx;
					_ty += __offy;
					
					var _clt  = __colLt[clti];
					var _c    = colorMultiply(__col, _clt);
					draw_set_color(_c);
					
					draw_text_transformed(_tx, _ty, _chr, 1, 1, _nor);
					__dwData[__dwDataI++] = [_tx, _ty, _chr, 1, 1, _nor];
					
					if(__outAtlas) array_push(__atlas, { 
						char : _chr, 
						x    : _tx, 
						y    : _ty, 
						rot  : _nor,
						sx   : 1, 
						sy   : 1, 
						
						blend : _c,
						halign: fa_left,
						valign: va, 
					});
					
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
					
					var clti = __dwDataI;
					switch(__colLtTyp) {
						case 0  : clti = __dwDataI % __colLtLen;                break;
						case 1  : clti = pingpong_value(__dwDataI, __colLtLen); break;
						case 2  : clti = irandom(__colLtLen - 1);               break;
					}
					
					var _clt = array_safe_get_fast(__colLt, clti);
					var _c   = colorMultiply(__col, _clt);
					draw_set_color(_c);
					
					_tx += __offx;
					_ty += __offy;
					
					draw_text_transformed(_tx, _ty, _chr, __temp_ss, __temp_ss, 0);
					__dwData[__dwDataI++] = [_tx, _ty, _chr, __temp_ss, __temp_ss, 0];
					
					if(__outAtlas) array_push(__atlas, { 
						char : _chr, 
						x    : _tx, 
						y    : _ty, 
						rot  : 0,
						sx   : __temp_ss, 
						sy   : __temp_ss, 
						
						blend : _c,
						halign: fa_left,
						valign: fa_top, 
					});
					
					__temp_tx += (string_width(_chr) + __temp_trck) * __temp_ss;
				});
			
				ty += (string_height(_str_line) + _line) * _ss;
			}
		}
		surface_reset_shader();
		
		array_resize(__dwData, __dwDataI);
		draw_data[_array_index] = __dwData;
		
		_outData[0] = _outSurf;
		
		if(__outAtlas) {
			var _currAtl = _outData[1];
			for( var i = 0, n = array_length(_currAtl); i < n; i++ )
				_currAtl[i].free();
			
			var _atlas = array_create(array_length(__atlas));
			draw_set_text(__f, fa_left, fa_top);
			
			for( var i = 0, n = array_length(__atlas); i < n; i++ ) {
				var _a = __atlas[i];
				
				var _ch = _a.char;
				var _sx = _a.sx;
				var _sy = _a.sy;
				
				var _ww = string_width(_ch)  * _sx;
				var _hh = string_height(_ch) * _sy;
				
				var _ss = surface_create(max(1, _ww), max(1, _hh));
				surface_set_shader(_ss);
					draw_set_color(_a.blend);
					draw_text_transformed(0, 0, _ch, _sx, _sy, _a.rot);
				surface_reset_shader();
				
				_atlas[i] = new SurfaceAtlas(_ss, _a.x, _a.y).setOriginalSurface(_outSurf);
			}
			
			_outData[1] = _atlas;
		}
		
		return _outData;
	}
}