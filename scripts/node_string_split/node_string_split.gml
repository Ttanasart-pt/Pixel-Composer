function Node_String_Split(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Split Text";
	always_pad = true;
	setDimension(96, 48);
	
	newInput( 0, nodeValue_Text("Text")).setVisible(true, true);
	
	////- =Split
	newInput( 2, nodeValue_EScroll( "Mode",       0, [ "Delimiter", "Periodic" ] ));
	newInput( 1, nodeValue_Text(    "Delimiter", " " )).setTooltip("Character that used to split text,\nleave blank to create character array.");
	newInput( 3, nodeValue_Int(     "Period",     1  ));
	newInput( 4, nodeValue_Bool(    "Trim white-space", false ));
	// 5
	
	newOutput(0, nodeValue_Output("Text", VALUE_TYPE.text, ""));
	
	inputs[1].getEditWidget().format = TEXT_AREA_FORMAT.delimiter;
	input_display_list = [ 0, 
		[ "Split", false ], 2, 1, 3, 4, 
	];
	
	////- Node
	
	static processData = function(_output, _data, _index = 0) { 
		#region data
			var _text = _data[0];
			
			var _mode = _data[2];
			var _deli = _data[1];
			var _peri = _data[3]; _peri = max(1, _peri);
			var _trim = _data[4];
			
			inputs[1].setVisible(_mode == 0);
			inputs[4].setVisible(_mode == 0);
			
			inputs[3].setVisible(_mode == 1);
		#endregion
		
		if(_deli == "") return string_to_array(_text);
			
		if(_mode == 0) {
			_deli = string_replace_all(_deli, "\\n", "\n");
			_deli = string_replace_all(_deli, "\\t", "\t");
			
			var arr = string_split(_text, _deli);
			
			if(_trim) {
				var d = [_deli];
				
				for( var i = 0, n = array_length(arr); i < n; i++ ) {
					arr[i] = string_trim_end(arr[i]);
					arr[i] = string_trim_end(arr[i], d);
				}
			}
			
			return arr;
			
		} else if(_mode == 1) {
			var _len = string_length(_text);
			var _amo = ceil(_len / _peri);
			var _arr = array_create(_amo);
			
			for( var i = 0; i < _amo; i++ ) {
				var _st = 1 + i * _peri;
				var _ed = min(_st + _peri, _len + 1);
				
				_arr[i] = string_copy(_text, _st, _ed - _st);
			}
			
			return _arr;
		}
		
		return [ _text ];
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		var cx   = bbox.xc;
		var cy   = bbox.yc;
		
		var _deli = getInputData(1);
		var _mode = getInputData(2);
		var _peri = getInputData(3);
		
		_s /= UI_SCALE;
		
		if(_mode == 0) {
			if(string_length(_deli) == 0) {
				draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text_sub);
				draw_text_bbox(bbox, __txt("None"));
				return;
			}
			
			_s *= 0.5;
			
			var _scis = gpu_get_scissor();
			gpu_set_scissor(bbox.x0 + 4 * _s, bbox.y0, bbox.w - 8 * _s, bbox.h);
			
			draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
			draw_text_add(cx, cy, _deli, _s);
			
			var ww = (string_width(_deli) / 2) * _s;
			draw_set_text(f_sdf, fa_right, fa_center, COLORS._main_text_sub);
			draw_text_transformed(cx - ww, cy, "|", _s, _s, 0);
			
			draw_set_halign(fa_left);
			draw_text_transformed(cx + ww, cy, "|", _s, _s, 0);
			
			gpu_set_scissor(_scis);
			
		} else if(_mode == 1) {
			
			_s *= 0.5;
			
			draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
			draw_text_add(cx, cy, _peri, _s);
			
			var ww = string_width(_peri)  * _s / 2 + 8 * _s;
			var hh = string_height(_peri) * _s / 2 - 6 * _s;
			
			draw_set_color(COLORS._main_text_sub);
			draw_line_round(cx - ww, cy + hh, cx + ww, cy + hh, 6 * _s);
		}
	}
}