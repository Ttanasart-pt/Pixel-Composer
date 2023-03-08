function Node_Color_Data(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "Color Data";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	inputs[| 0].setVisible(true, true);
	
	outputs[| 0] = nodeValue("Red", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 1] = nodeValue("Green", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 2] = nodeValue("Blue", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	outputs[| 3] = nodeValue("Hue", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 4] = nodeValue("Saturation", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 5] = nodeValue("Value", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	outputs[| 6] = nodeValue("Brightness", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	function process_data(_output, _data, _output_index, _array_index = 0) {  
		var c = _data[0];
		
		switch(_output_index) {
			case 0 : return color_get_red(c) / 255;
			case 1 : return color_get_green(c) / 255;
			case 2 : return color_get_blue(c) / 255;
			
			case 3 : return color_get_hue(c) / 255;
			case 4 : return color_get_saturation(c) / 255;
			case 5 : return color_get_value(c) / 255;
			
			case 6 : 
				var r = color_get_red(c) / 255;
				var g = color_get_green(c) / 255;
				var b = color_get_blue(c) / 255;
				return 0.299 * r + 0.587 * g + 0.224 * b;
		}
	}
	
	PATCH_STATIC
}