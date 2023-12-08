function Node_Text(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Text";
	font = f_p0;
	
	inputs[| 0] = nodeValue("Text", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "")
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Font", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_font);
	
	inputs[| 2] = nodeValue("Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 16);
	
	inputs[| 3] = nodeValue("Anti-Aliasing ", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 4] = nodeValue("Character range", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 32, 128 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 5] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 6] = nodeValue("Fixed dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(true, false);
	
	inputs[| 7] = nodeValue("Horizontal alignment", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ THEME.inspector_text_halign, THEME.inspector_text_halign, THEME.inspector_text_halign]);
	
	inputs[| 8] = nodeValue("Vertical alignment", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ THEME.inspector_text_valign, THEME.inspector_text_valign, THEME.inspector_text_valign ]);
	
	inputs[| 9] = nodeValue("Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Fixed", "Dynamic" ]);
	
	inputs[| 10] = nodeValue("Padding", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0, 0, 0])
		.setDisplay(VALUE_DISPLAY.padding);
	
	inputs[| 11] = nodeValue("Letter spacing", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 12] = nodeValue("Line height", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 13] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone)
		.setVisible(true, true);
	
	inputs[| 14] = nodeValue("Path shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 15] = nodeValue("Scale to fit", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 16] = nodeValue("Render background", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 17] = nodeValue("BG Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	input_display_list = [
		["Output",		true],	9, 6, 10,
		["Text",		false], 0, 13, 14, 7, 8, 
		["Font",		false], 1, 2, 15, 3, 11, 12, 
		["Rendering",	false], 5, 16, 17, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	_font_current = "";
	_size_current = 0;
	_aa_current   = false;
	
	static generateFont = function(_path, _size, _aa) { #region
		if(PROJECT.animator.is_playing) return;
		if(_path == _font_current && _size == _size_current && _aa == _aa_current) return;
		 
		_font_current    = _path;
		_size_current    = _size;
		_aa_current      = _aa;
		
		if(!file_exists_empty(_path)) return;
		
		if(font != f_p0 && font_exists(font)) 
			font_delete(font);
			
		font_add_enable_aa(_aa);
		font = _font_add(_path, _size);
	} #endregion
	
	static step = function() { #region
		var _dimt = getSingleValue(9);
		var _path = getSingleValue(13);
		var _ubg  = getSingleValue(16);
		
		var _use_path = _path != noone && struct_has(_path, "getPointDistance");
		
		inputs[|  6].setVisible(_dimt == 0 || _use_path);
		inputs[|  7].setVisible(_dimt == 0 || _use_path);
		inputs[|  8].setVisible(_dimt == 0 || _use_path);
		inputs[|  9].setVisible(!_use_path);
		inputs[| 14].setVisible( _use_path);
		inputs[| 15].setVisible(_dimt == 0 && !_use_path);
		inputs[| 17].setVisible(_ubg);
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var str   = _data[0];
		var _font = _data[1];
		var _size = _data[2];
		var _aa   = _data[3];
		var _col  = _data[5];
		var _dim  = _data[6];
		var _hali = _data[7];
		var _vali = _data[8];
		var _dim_type = _data[9];
		var _padd = _data[10];
		var _trck = _data[11];
		var _line = _data[12];
		var _path = _data[13];
		var _pthS = _data[14];
		var _scaF = _data[15];
		var _ubg  = _data[16];
		var _bgc  = _data[17];
		
		generateFont(_font, _size, _aa);
		draw_set_font(font);
		
		var _str_lines   = string_splice(str, "\n");
		_line_widths = [];
		
		var ww = 0, _sw = 0;
		var hh = 0, _sh = 0;
		
		__temp_len  = string_length(str);
		__temp_lw   = 0;
		__temp_ww   = 0;
		__temp_hh   = line_get_height();
		__temp_trck = _trck;
		__temp_line = _line;
			
		string_foreach(str, function(_chr, _ind) {
			if(_chr == "\n") {
				var _lw = max(0, __temp_lw - __temp_trck);
				array_push(_line_widths, _lw);
				__temp_ww = max(__temp_ww, _lw);
				__temp_hh += string_height(_chr) + __temp_line;
				__temp_lw = 0;
			} else
				__temp_lw += string_width(_chr) + __temp_trck;
		});
			
		var _lw = max(0, __temp_lw - __temp_trck);
		array_push(_line_widths, _lw);
		__temp_ww = max(__temp_ww, _lw);
		ww = __temp_ww;
		hh = __temp_hh;
		
		var _use_path = _path != noone && struct_has(_path, "getPointDistance");
		var _ss = 1;
		
		if(_use_path || _dim_type == 0) {
			_sw = _dim[0];
			_sh = _dim[1];
		} else {
			_sw = ww;
			_sh = hh;
		}
		
		if(_dim_type == 0 && !_use_path && _scaF)
			_ss = min(_sw / ww, _sh / hh);
		
		_sw += _padd[PADDING.left] + _padd[PADDING.right];
		_sh += _padd[PADDING.top] + _padd[PADDING.bottom];
		_outSurf = surface_verify(_outSurf, _sw, _sh, attrDepth());
		
		var tx = 0, ty = _padd[PADDING.top], _ty = 0;
		if(_dim_type == 0) {
			switch(_vali) {
				case 0 : ty = _padd[PADDING.top];						break;
				case 1 : ty = (_sh - hh * _ss) / 2;						break;
				case 2 : ty = _sh - _padd[PADDING.bottom] - hh * _ss;	break;
			}
		}
		
		surface_set_shader(_outSurf, noone,, BLEND.alpha);
			if(_ubg) {
				draw_clear(_bgc);
				BLEND_ALPHA_MULP
			}
			
			for( var i = 0, n = array_length(_str_lines); i < n; i++ ) {
				var _str_line   = _str_lines[i];
				var _line_width = _line_widths[i];
				
				if(_use_path) {
					draw_set_text(font, fa_left, fa_bottom, _col);
					tx = _pthS;
					ty = 0;
					
					switch(_hali) {
						case 0 : tx = _pthS;					break;
						case 1 : tx = _pthS - _line_width / 2;	break;
						case 2 : tx = _line_width - _pthS;		break;
					}
					
					switch(_vali) {
						case 0 : ty = _ty;				break;
						case 1 : ty = -hh / 2 + _ty;	break;
						case 2 : ty = -hh + _ty;		break;
					}
					
					__temp_tx = tx;
					__temp_ty = ty;
					__temp_pt = _path;
					
					string_foreach(_str_line, function(_chr, _ind) {
						var _pos = __temp_pt.getPointDistance(__temp_tx);
						var _p2  = __temp_pt.getPointDistance(__temp_tx + 0.1);
						var _nor = point_direction(_pos.x, _pos.y, _p2.x, _p2.y);
						
						var _line_ang = _nor - 90;
						var _dx = lengthdir_x(__temp_ty, _line_ang);
						var _dy = lengthdir_y(__temp_ty, _line_ang);
						
						draw_text_transformed(_pos.x + _dx, _pos.y + _dy, _chr, 1, 1, _nor);
						__temp_tx += string_width(_chr) + __temp_trck;
					});
					
					_ty += line_get_height() + _line;
				} else {
					draw_set_text(font, fa_left, fa_top, _col);
					tx = _padd[PADDING.left];
					
					if(_dim_type == 0) 
					switch(_hali) {
						case 0 : tx = _padd[PADDING.left];								break;
						case 1 : tx = (_sw - _line_width * _ss) / 2;					break;
						case 2 : tx = _sw - _padd[PADDING.right] - _line_width * _ss;	break;
					}
					
					__temp_tx   = tx;
					__temp_ty   = ty;
					__temp_ss   = _ss;
					__temp_trck = _trck;
				
					string_foreach(_str_line, function(_chr, _ind) {
						draw_text_transformed(__temp_tx, __temp_ty, _chr, __temp_ss, __temp_ss, 0);
						__temp_tx += (string_width(_chr) + __temp_trck) * __temp_ss;
					});
				
					ty += (line_get_height() + _line) * _ss;
				}
			}
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}