function Node_PB_Fx_Stack(_x, _y, _group = noone) : Node_PB_Fx(_x, _y, _group) constructor {
	name = "Stack";
	
	inputs[| 1] = nodeValue("Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4 );
	
	inputs[| 2] = nodeValue("Direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, array_create(4, THEME.obj_direction) );
	
	inputs[| 3] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 4] = nodeValue("Highlight", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	inputs[| 5] = nodeValue("Highlight Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 6] = nodeValue("Invert", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	input_display_list = [ 0,
		["Effect",	false], 1, 2, 6, 3, 4, 5, 
	];
	
	static step = function() {
		var _high = current_data[4];
		
		inputs[| 5].setVisible(_high);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _pbox = _data[0];
		if(_pbox == noone) return _pbox;
		
		var _nbox = _pbox.clone();
		
		var _amou = _data[1];
		var _dirr = _data[2];
		var _colr = _data[3];
		var _high = _data[4];
		var _hclr = _data[5];
		var _invr = _data[6];
		
		surface_set_target(_nbox.content);
			DRAW_CLEAR
			var px = 0;
			var py = 0;
			
			if(_invr) {
				switch(_dirr) {
					case 0 : px = -_amou; break;
					case 1 : py =  _amou; break;
					case 2 : px =  _amou; break;
					case 3 : py = -_amou; break;
				}
			}
			
			shader_set(sh_draw_color);
			for( var i = 0; i < _amou; i++ ) {
				var cc = _colr;
				if(_high && i == _amou - 1)
					cc = _hclr;
				draw_surface_ext_safe(_pbox.content, px, py,,,, cc);
				
				switch(_dirr) {
					case 0 : px++; break;
					case 1 : py--; break;
					case 2 : px--; break;
					case 3 : py++; break;
				}
			}
			shader_reset();
			
			draw_surface_safe(_pbox.content, px, py);
		surface_reset_target();
		
		return _nbox;
	}
}