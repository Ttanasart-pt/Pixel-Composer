function Node_Color_Data(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "Color Data";
	
	w = 96;
	
	inputs[| 0] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Normalize", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	outputs[| 0] = nodeValue("Red", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 1] = nodeValue("Green", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 2] = nodeValue("Blue", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	outputs[| 3] = nodeValue("Hue", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 4] = nodeValue("Saturation", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 5] = nodeValue("Value", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	outputs[| 6] = nodeValue("Brightness", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		var _c = _data[0];
		var _n = _data[1];
		
		var val = 0;
		switch(_output_index) {
			case 0 : val = color_get_red(_c);		break;
			case 1 : val = color_get_green(_c);		break;
			case 2 : val = color_get_blue(_c);		break;
			
			case 3 : val = color_get_hue(_c);			break;
			case 4 : val = color_get_saturation(_c);	break;
			case 5 : val = color_get_value(_c);			break;
			
			case 6 : 
				var r = color_get_red(_c);
				var g = color_get_green(_c);
				var b = color_get_blue(_c);
				val   = 0.2126 * r + 0.7152 * g + 0.0722 * b;
				break;
		}
		
		return _n? val / 255 : val;
	}
	
	PATCH_STATIC
}