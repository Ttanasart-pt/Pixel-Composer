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
	
	input_display_list = [
		["Output",			true],	9, 6, 10,
		["Text",			false], 0, 7, 8, 5, 
		["Font properties", false], 1, 2, 3,
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	_font_current = "";
	_size_current = 0;
	_aa_current   = false;
	
	static generateFont = function(_path, _size, _aa) {
		if(PROJECT.animator.is_playing) return;
		if(_path == _font_current && _size == _size_current && _aa == _aa_current) return;
		 
		_font_current    = _path;
		_size_current    = _size;
		_aa_current      = _aa;
		
		if(!file_exists(_path)) return;
		
		if(font != f_p0 && font_exists(font)) 
			font_delete(font);
			
		font_add_enable_aa(_aa);
		font = _font_add(_path, _size);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var str    = _data[0];
		var _font  = _data[1];
		var _size  = _data[2];
		var _aa    = _data[3];
		var _col   = _data[5];
		
		var _dim_type = _data[9];
		inputs[| 6].setVisible(!_dim_type);
		
		var _dim   = _data[6];
		var _padd  = _data[10];
		
		var ww, hh;
		
		generateFont(_font, _size, _aa);
		
		draw_set_font(font);
		if(_dim_type == 0) {
			ww = _dim[0];
			hh = _dim[1];
		} else {
			ww = max(1, string_width(str));
			hh = max(1, string_height(str));
		}
		
		ww += _padd[PADDING.left] + _padd[PADDING.right];
		hh += _padd[PADDING.top] + _padd[PADDING.bottom];
		_outSurf = surface_verify(_outSurf, ww, hh, attrDepth());
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			BLEND_ALPHA
			
			if(_dim[0] != 0 && _dim[1] != 0) {
				var _hali = _data[7];
				var _vali = _data[8];
				
				var tx = 0, ty = 0;
				draw_set_text(font, fa_left, fa_top, _col);
				switch(_hali) {
					case 0 : draw_set_halign(fa_left);		tx = 0;			break;
					case 1 : draw_set_halign(fa_center);	tx = ww / 2;	break;
					case 2 : draw_set_halign(fa_right);		tx = ww;		break;
				}
				switch(_vali) {
					case 0 : draw_set_valign(fa_top);		ty = 0;			break;
					case 1 : draw_set_valign(fa_middle);	ty = hh / 2;	break;
					case 2 : draw_set_valign(fa_bottom);	ty = hh;		break;
				}
				
				draw_text(_padd[PADDING.left] + tx, _padd[PADDING.top] + ty, str);
			} else {
				draw_set_text(font, fa_left, fa_top, _col);
				draw_text(_padd[PADDING.left], _padd[PADDING.top], str);
			}
			
			BLEND_NORMAL;
		surface_reset_target();
		
		return _outSurf;
	}
}