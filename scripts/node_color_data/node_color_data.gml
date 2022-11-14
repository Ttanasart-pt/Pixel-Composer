function Node_create_Color_Data(_x, _y) {
	var node = new Node_Color_Data(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Color_Data(_x, _y) : Node_Value_Processor(_x, _y) constructor {
	name		= "Color data";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue(0, "Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	inputs[| 0].setVisible(true, true);
	
	outputs[| 0] = nodeValue(0, "Red", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 1] = nodeValue(1, "Green", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 2] = nodeValue(2, "Blue", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	outputs[| 3] = nodeValue(3, "Hue", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 4] = nodeValue(4, "Saturation", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 5] = nodeValue(5, "Value", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	outputs[| 6] = nodeValue(6, "Brightness", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	function process_value_data(_data, index = 0) { 
		var c = _data[0];
		
		switch(index) {
			case 0 : return color_get_red(c);
			case 1 : return color_get_green(c);
			case 2 : return color_get_blue(c);
			
			case 3 : return color_get_hue(c);
			case 4 : return color_get_saturation(c);
			case 5 : return color_get_value(c);
			
			case 6 : 
				var r = color_get_red(c);
				var g = color_get_green(c);
				var b = color_get_blue(c);
				return 0.299 * r + 0.587 * g + 0.224 * b;
		}
	}
	
	doUpdate();
}