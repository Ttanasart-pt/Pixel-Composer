function Node_Color_Data(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Color Data";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Color("Color", self, ca_white))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Bool("Normalize", self, true));
	
	// newInput(2, nodeValue_Enum_Scroll("Brightness Eq", self, 0, [ "Perceived", "" ]));
	
	newOutput(0, nodeValue_Output("Red", 		self, VALUE_TYPE.float, 0));
	newOutput(1, nodeValue_Output("Green",		self, VALUE_TYPE.float, 0));
	newOutput(2, nodeValue_Output("Blue",		self, VALUE_TYPE.float, 0));
	
	newOutput(3, nodeValue_Output("Hue", 		self, VALUE_TYPE.float, 0).setVisible(false));
	newOutput(4, nodeValue_Output("Saturation",	self, VALUE_TYPE.float, 0).setVisible(false));
	newOutput(5, nodeValue_Output("Value",		self, VALUE_TYPE.float, 0).setVisible(false));
	
	newOutput(6, nodeValue_Output("Brightness",	self, VALUE_TYPE.float, 0).setVisible(false));
	newOutput(7, nodeValue_Output("Alpha",		self, VALUE_TYPE.float, 0).setVisible(false));
	
	static processData = function(_outData, _data, _array_index = 0) {  
		var _c = _data[0];
		var _n = _data[1];
		
		if(!is_numeric(_c)) return _outData;
		
		if(_n) {
			_outData[0] = _color_get_red(_c);
			_outData[1] = _color_get_green(_c);
			_outData[2] = _color_get_blue(_c);
			
			_outData[3] = _color_get_hue(_c);
			_outData[4] = _color_get_saturation(_c);
			_outData[5] = _color_get_value(_c);
			
			_outData[6] = sqrt(.241 * _outData[0] * _outData[0] + .691 * _outData[1] * _outData[1] + .068 * _outData[2] * _outData[2]);
			_outData[7] = _color_get_alpha(_c);
			
		} else {
			_outData[0] = color_get_red(_c);
			_outData[1] = color_get_green(_c);
			_outData[2] = color_get_blue(_c);
			
			_outData[3] = color_get_hue(_c);
			_outData[4] = color_get_saturation(_c);
			_outData[5] = color_get_value(_c);
			
			_outData[6] = sqrt(.241 * _outData[0] * _outData[0] + .691 * _outData[1] * _outData[1] + .068 * _outData[2] * _outData[2]);
			_outData[7] = color_get_alpha(_c);
		}
		
		return _outData;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_sdf, fa_right, fa_center, COLORS._main_text);
		
		for(var i = 0; i < array_length(outputs); i++) {
			var val = outputs[i];
			if(!val.isVisible()) continue;
			
			var _bx1 = bbox.x1 -  8 * _s;
			var _bx0 = _bx1    - 20 * _s;
			
			var _by  = val.y;
			var _by0 = _by - 8 * _s;
			var _by1 = _by + 8 * _s;
			
			draw_sprite_stretched_points(s_node_color_data_label, i, _bx0, _by0, _bx1, _by1);
		}
	}
	
}