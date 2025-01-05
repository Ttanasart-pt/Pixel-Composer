function Node_Text(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Text";
	font = f_p0;
	
	dimension_index = -1;
	
	newInput(0, nodeValue_Text("Text", self, ""))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Path("Font", self, ""))
		.setDisplay(VALUE_DISPLAY.path_font);
	
	newInput(2, nodeValue_Int("Size", self, 16));
	
	newInput(3, nodeValue_Bool("Anti-Aliasing ", self, false));
	
	newInput(4, nodeValue_Vec2("Character range", self, [ 32, 128 ]));
	
	newInput(5, nodeValue_Color("Color", self, cola(c_white)));
	
	newInput(6, nodeValue_Vec2("Fixed dimension", self, DEF_SURF ))
		.setVisible(true, false);
	
	newInput(7, nodeValue_Enum_Button("H align", self,  0 , [ THEME.inspector_text_halign, THEME.inspector_text_halign, THEME.inspector_text_halign]));
	
	newInput(8, nodeValue_Enum_Button("V align", self,  0 , [ THEME.inspector_text_valign, THEME.inspector_text_valign, THEME.inspector_text_valign ]));
	
	newInput(9, nodeValue_Enum_Scroll("Output dimension", self,  1 , [ "Fixed", "Dynamic" ]));
	
	newInput(10, nodeValue_Padding("Padding", self, [0, 0, 0, 0]));
	
	newInput(11, nodeValue_Float("Letter spacing", self, 0));
	
	newInput(12, nodeValue_Float("Line height", self, 0));
	
	newInput(13, nodeValue_PathNode("Path", self, noone))
		.setVisible(true, true);
	
	newInput(14, nodeValue_Float("Path shift", self, 0));
	
	newInput(15, nodeValue_Bool("Scale to fit", self, false));
	
	newInput(16, nodeValue_Bool("Render background", self, false));
	
	newInput(17, nodeValue_Color("BG Color", self, cola(c_black)));
	
	newInput(18, nodeValue_Bool("Wave", self, false));
	
	newInput(19, nodeValue_Float("Wave amplitude", self, 4));
	
	newInput(20, nodeValue_Float("Wave scale", self, 30));
	
	newInput(21, nodeValue_Rotation("Wave phase", self, 0));
	
	newInput(22, nodeValue_Float("Wave shape", self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 3, 0.01 ] });
	
	newInput(23, nodeValue_Bool("Typewriter", self, false));
	
	newInput(24, nodeValue_Slider_Range("Range", self, [ 0, 1 ]));
	
	newInput(25, nodeValue_Enum_Button("Trim type", self,  0 , [ "Character", "Word", "Line" ]));
	
	newInput(26, nodeValue_Bool("Use full text size", self, true ));
	
	newInput(27, nodeValue_Int("Max line width", self, 0 ));
	
	newInput(28, nodeValue_Bool("Round position", self, true ));
		
	input_display_list = [ 0, 
		["Output",		true],	9,  6, 10,
		["Alignment",	false], 13, 14, 7, 8, 27, 
		["Font",		false], 1,  2, 15, 3, 11, 12, 
		["Rendering",	false], 5, 
		["Background",   true, 16], 17, 
		["Wave",	     true, 18], 22, 19, 20, 21, 
		["Trim",		 true, 23], 25, 24, 26, 
	];
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	 
	attribute_surface_depth();
	
	_font_current = "";
	_size_current = 0;
	_aa_current   = false;
	seed          = seed_random();
	
	static generateFont = function(_path, _size, _aa) {
		if(PROJECT.animator.is_playing) return;
		if(font_exists(font) && _path == _font_current && _size == _size_current && _aa == _aa_current) return;
		
		_font_current = _path;
		_size_current = _size;
		_aa_current   = _aa;
		
		if(!file_exists_empty(_path)) return;
		
		if(font != f_p0 && font_exists(font)) 
			font_delete(font);
			
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
		
		inputs[ 2].setVisible(_font != "");
		inputs[ 3].setVisible(_font != "");
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
		var  hv  = inputs[13].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= bool(hv);
		
		return _hov;
	}
	
	static getTool = function() { 
		var _path = getInputData(13);
		return is_instanceof(_path, Node)? _path : self; 
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var str    = _data[ 0];
		var strRaw = str;
		
		var _font  = _data[ 1];
		var _size  = _data[ 2];
		var _aa    = _data[ 3];
		var _col   = _data[ 5];
		var _dim   = _data[ 6];
		var _hali  = _data[ 7];
		var _vali  = _data[ 8];
		var _dimt  = _data[ 9];
		var _padd  = _data[10];
		var _trck  = _data[11];
		var _line  = _data[12];
		var _path  = _data[13];
		var _pthS  = _data[14];
		var _scaF  = _data[15];
		var _ubg   = _data[16];
		var _bgc   = _data[17];
		
		var _wave  = _data[18];
		var _waveA = _data[19];
		var _waveS = _data[20];
		var _waveP = _data[21];
		var _waveH = _data[22];
		
		var _type  = _data[23];
		var _typeR = _data[24];
		var _typeC = _data[25];
		var _typeF = _data[26];
		
		var _lineW = _data[27];
		__rnd_pos  = _data[28];
		
		generateFont(_font, _size, _aa);
		draw_set_font(font);
		
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
		
		surface_set_shader(_outSurf, noone,, BLEND.alpha);
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
				case 0 : ty = 0;                							va = fa_top;         break;
				case 1 : ty = (_max_hh - line_get_height(font)) / 2;    	va = fa_center;      break;
				case 2 : ty = _max_hh;          							va = fa_top;         break;
			}
			
			for( var i = 0, n = array_length(_str_lines); i < n; i++ ) {
				var _str_line   = _str_lines[i];
				var _line_width = _line_widths[i];
				draw_set_text(font, fa_left, va, _col);
				
				switch(_hali) {
					case 0 : tx = 0;                           break;
					case 1 : tx = _pthl / 2 - _line_width / 2; break;
					case 2 : tx = _pthl     - _line_width;     break;
				}
				
				__temp_tx = tx + _pthS;
				__temp_ty = ty;
				__temp_p0 = new __vec2();
				__temp_p1 = new __vec2();
				
				string_foreach(_str_line, function(_chr, _ind) {
					var _p1  = __temp_pt.getPointDistance(__temp_tx,      0, __temp_p0);
					var _p2  = __temp_pt.getPointDistance(__temp_tx + .1, 0, __temp_p1);
					var _nor = point_direction(_p1.x, _p1.y, _p2.x, _p2.y);
					
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
					__temp_tx += string_width(_chr) + __temp_trck;
				});
				
				ty -= string_height(_str_line) + _line;
			}
			
		} else {
			for( var i = 0, n = array_length(_str_lines); i < n; i++ ) {
				var _str_line   = _str_lines[i];
				var _line_width = _line_widths[i];
				draw_set_text(font, fa_left, fa_top, _col);
				tx = _padd[PADDING.left];
				
				if(_dimt == 0) 
				switch(_hali) {
					case 0 : tx = _padd[PADDING.left];								break;
					case 1 : tx = (_sw - _line_width * _ss) / 2;					break;
					case 2 : tx = _sw - _padd[PADDING.right] - _line_width * _ss;	break;
				}
				
				__temp_tx = tx;
				__temp_ty = ty;
			
				string_foreach(_str_line, function(_chr, _ind) {
					var _tx = __temp_tx;
					var _ty = __temp_ty;
					
					if(__wave) {
						var _wd = waveGet(_ind);
						_ty += _wd;
					}
					
					if(__rnd_pos) { _tx = round(_tx); _ty = round(_ty); }
					
					draw_text_transformed(_tx, _ty, _chr, __temp_ss, __temp_ss, 0);
					__temp_tx += (string_width(_chr) + __temp_trck) * __temp_ss;
				});
			
				ty += (string_height(_str_line) + _line) * _ss;
			}
		}
		surface_reset_shader();
		
		return _outSurf;
	}
}