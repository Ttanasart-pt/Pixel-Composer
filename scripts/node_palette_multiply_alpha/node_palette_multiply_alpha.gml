function Node_Palette_Multiply_Alpha(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Multiply Alpha Palette";
	setDimension(96);
	
	////- =Palette
	newInput( 0, nodeValue_Palette( "Palette In" )).setVisible(true, true);
	// 1
	
	newOutput(0, nodeValue_Output( "Palette Out", VALUE_TYPE.color, [])).setDisplay(VALUE_DISPLAY.palette);
	
	input_display_list = [
		[ "Palette", false ],  0, 
	];
	
	////- Node
	
	static processData_prebatch = function() {
		setDimension(96, process_length[0] * 32);
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _pal = _data[0];
			
			if(!is_array(_pal)) return [];
		#endregion
		
		var _out = array_clone(_pal);
		for( var i = 0, n = array_length(_out); i < n; i++ ) {
			var _col = _out[i];
			var _alp = _color_get_a(_col);
			
			_out[i] = _make_color_rgba(
				_color_get_r(_col) * _alp,
				_color_get_g(_col) * _alp,
				_color_get_b(_col) * _alp,
				_color_get_a(_col),
			)
		}
		
		return _out;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		if(bbox.h < 1) return;
		
		var pal = outputs[0].getValue();
		if(array_empty(pal)) return;
		if(!is_array(pal[0])) pal = [ pal ];
		
		var _y = bbox.y0;
		var gh = bbox.h / array_length(pal);
			
		for( var i = 0, n = array_length(pal); i < n; i++ ) {
			drawPalette(pal[i], bbox.x0, _y, bbox.w, gh);
			_y += gh;
		}
	}
}