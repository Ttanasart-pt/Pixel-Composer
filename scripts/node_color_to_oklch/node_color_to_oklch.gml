function Node_Color_to_OKLCH(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Color OKLCH";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Color("Color", self, cola(c_white)))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Lightness", self, VALUE_TYPE.float, 0));
	newOutput(1, nodeValue_Output("Chroma",    self, VALUE_TYPE.float, 0));
	newOutput(2, nodeValue_Output("Hue",       self, VALUE_TYPE.float, 0));
	
	static processData = function(_outData, _data, _output_index, _array_index = 0) {  
		var _c = _data[0];
		
		if(!is_numeric(_c)) return _outData;
		
		var _lch = rgb2oklch([
		    _color_get_red(_c),
            _color_get_green(_c),
            _color_get_blue(_c),
	    ]);
		
		_outData[0] = _lch[0];
		_outData[1] = _lch[1];
		_outData[2] = _lch[2];
		
		return _outData;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_set_text(f_sdf, fa_right, fa_center, COLORS._main_text);
		
		for(var i = 0; i < array_length(outputs); i++) {
			var val = outputs[i];
			if(!val.isVisible()) continue;
			
			var tx = bbox.x1 -  8 * _s;
			var ty = val.y;
			
			draw_text_ext_add(tx, ty, string_char_at(val.name, 1), -1, w * _s, _s * .25);
		}
	}
}