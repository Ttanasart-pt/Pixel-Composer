function Node_create_Text(_x, _y) {
	var node = new Node_Text(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Text(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "Text";
	
	font = f_p0;
	
	inputs[| 0] = nodeValue(0, "Text", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
	
	inputs[| 1] = nodeValue(1, "Font", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_load, ["*.ttf;*.otf", ""]);
	
	inputs[| 2] = nodeValue(2, "Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 16);
	
	inputs[| 3] = nodeValue(3, "Anti-Aliasing ", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 4] = nodeValue(4, "Character range", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 32, 128 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 5] = nodeValue(5, "Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 6] = nodeValue(6, "Fixed dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2, VALUE_TAG.dimension_2d )
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(true, false);
	
	inputs[| 7] = nodeValue(7, "Horizontal alignment", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ s_inspector_text_halign, s_inspector_text_halign, s_inspector_text_halign]);
	
	inputs[| 8] = nodeValue(8, "Vertical alignment", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ s_inspector_text_valign, s_inspector_text_valign, s_inspector_text_valign ]);
	
	inputs[| 9] = nodeValue(9, "Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Fixed", "Dynamic" ]);
	
	inputs[| 10] = nodeValue(10, "Padding", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0, 0, 0])
		.setDisplay(VALUE_DISPLAY.padding);
	
	input_display_list = [
		["Output",			true],	9, 6, 10,
		["Text",			false], 0, 7, 8, 5, 
		["Font properties", false], 1, 2, 3, 4
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	_font_current = "";
	_size_current = 0;
	_aa_current   = false;
	_rang_current = [0, 0];
	
	static generateFont = function(_path, _size, _aa, _range) {
		if(ANIMATOR.is_playing) return;
		
		if(_path == _font_current && _size == _size_current && _aa == _aa_current && _rang_current[0] == _range[0] && _rang_current[1] == _range[1]) return;
		_font_current    = _path;
		_size_current    = _size;
		_aa_current      = _aa;
		_rang_current[0] = _range[0];
		_rang_current[1] = _range[1];
		
		if(file_exists(_path)) {
			if(font != f_p0 && font_exists(font)) 
				font_delete(font);
			font_add_enable_aa(_aa);
			font = font_add(_path, _size, false, false, _range[0], _range[1]);
		}
	}
	
	static process_data = function(_outSurf, _data, _output_index) {
		var str    = _data[0];
		var _font  = _data[1];
		var _size  = _data[2];
		var _aa    = _data[3];
		var _range = _data[4];
		var _col   = _data[5];
		
		var _dim_type = _data[9];
		inputs[| 6].setVisible(!_dim_type);
		
		var _dim   = _data[6];
		var _padd  = _data[10];
		
		var ww, hh;
		
		generateFont(_font, _size, _aa, _range);
		
		draw_set_font(font);
		if(_dim_type == 0) {
			ww = _dim[0];
			hh = _dim[1];
		} else {
			ww = max(1, string_width(str));
			hh = max(1, string_height(str));
		}
		
		ww += _padd[PADDING.left] + _padd[PADDING.right];
		hh += _padd[PADDING.up] + _padd[PADDING.down];
		
		if(is_surface(_outSurf)) 
			surface_size_to(_outSurf, ww, hh);
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_ADD
			
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
				
				draw_text(_padd[PADDING.left] + tx, _padd[PADDING.up] + ty, str);
			} else {
				draw_set_text(font, fa_left, fa_top, _col);
				draw_text(_padd[PADDING.left], _padd[PADDING.up], str);
			}
			
			BLEND_NORMAL
		surface_reset_target();
	}
}