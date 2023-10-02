function Node_Color_Mix(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "Mix Color";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Color from", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 1] = nodeValue("Color to", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 2] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 3] = nodeValue("Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "RGB", "HSV" ]);
	
	outputs[| 0] = nodeValue("Color", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, c_white);
	
	input_display_list = [ 3, 0, 1, 2 ];
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		switch(_data[3]) {
			case 0 : return merge_color(_data[0], _data[1], _data[2]);
			case 1 :
				var h0 = color_get_hue(_data[0]);
				var s0 = color_get_saturation(_data[0]);
				var v0 = color_get_value(_data[0]);
				
				var h1 = color_get_hue(_data[1]);
				var s1 = color_get_saturation(_data[1]);
				var v1 = color_get_value(_data[1]);
				
				return make_color_hsv(
					lerp(h0, h1, _data[2]),
					lerp(s0, s1, _data[2]),
					lerp(v0, v1, _data[2]),
				);
		}
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var col = outputs[| 0].getValue();
		
		if(is_array(col)) {
			drawPalette(col, bbox.x0, bbox.y0, bbox.w, bbox.h);
			return;
		}
		
		draw_set_color(col);
		draw_rectangle(bbox.x0, bbox.y0, bbox.x1, bbox.y1, 0);
	}
}