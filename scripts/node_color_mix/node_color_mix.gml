function Node_Color_Mix(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Mix Color";
	setDimension(96, 48);;
	
	inputs[| 0] = nodeValue("Color from", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 1] = nodeValue("Color to", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 2] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 3] = nodeValue("Color space", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "RGB", "HSV", "OKLAB" ]);
	
	outputs[| 0] = nodeValue("Color", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, c_white);
	
	input_display_list = [ 3, 0, 1, 2 ];
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		var c = c_black;
		
		switch(_data[3]) {
			case 0 : c = merge_color_ext(  _data[0], _data[1], _data[2]); break;
			case 1 : c = merge_color_hsv(  _data[0], _data[1], _data[2]); break;
			case 2 : c = merge_color_oklab(_data[0], _data[1], _data[2]); break;
		}
		
		return c;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var col = outputs[| 0].getValue();
		
		if(is_array(col)) {
			drawPalette(col, bbox.x0, bbox.y0, bbox.w, bbox.h);
			return;
		}
		
		drawColor(col, bbox.x0, bbox.y0, bbox.w, bbox.h);
	}
}