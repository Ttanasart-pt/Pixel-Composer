function Node_Color_Data(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Color Data";
	batch_output = false;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Color("Color", self, c_white))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Bool("Normalize", self, true));
	
	newOutput(0, nodeValue_Output("Red", 		self, VALUE_TYPE.float, 0));
	newOutput(1, nodeValue_Output("Green",		self, VALUE_TYPE.float, 0));
	newOutput(2, nodeValue_Output("Blue",		self, VALUE_TYPE.float, 0));
	
	newOutput(3, nodeValue_Output("Hue", 		self, VALUE_TYPE.float, 0).setVisible(false));
	newOutput(4, nodeValue_Output("Saturation",	self, VALUE_TYPE.float, 0).setVisible(false));
	newOutput(5, nodeValue_Output("Value",		self, VALUE_TYPE.float, 0).setVisible(false));
	
	newOutput(6, nodeValue_Output("Brightness",	self, VALUE_TYPE.float, 0).setVisible(false));
	newOutput(7, nodeValue_Output("Alpha",		self, VALUE_TYPE.float, 0).setVisible(false));
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		var _c = _data[0];
		var _n = _data[1];
		
		var val = 0;
		switch(_output_index) {
			case 0 : val = color_get_red(_c);			break;
			case 1 : val = color_get_green(_c);			break;
			case 2 : val = color_get_blue(_c);			break;
			
			case 3 : val = color_get_hue(_c);			break;
			case 4 : val = color_get_saturation(_c);	break;
			case 5 : val = color_get_value(_c);			break;
			
			case 6 : 
				var r = color_get_red(_c);
				var g = color_get_green(_c);
				var b = color_get_blue(_c);
				val   = 0.2126 * r + 0.7152 * g + 0.0722 * b;
				break;
			
			case 7 : val = color_get_alpha(_c);			break;
		}
		
		return _n? val / 255 : val;
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
			var _by0 = _by - 10 * _s;
			var _by1 = _by + 10 * _s;
			
			draw_sprite_stretched_points(s_node_color_data_label, i, _bx0, _by0, _bx1, _by1);
		}
	}
	
}