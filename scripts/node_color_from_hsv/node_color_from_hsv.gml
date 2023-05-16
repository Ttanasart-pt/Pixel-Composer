function Node_Color_HSV(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "HSV Color";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Hue", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01])
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Saturation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01])
		.setVisible(true, true);
	
	inputs[| 2] = nodeValue("Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01])
		.setVisible(true, true);
	
	inputs[| 3] = nodeValue("Normalized", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, 1);
	
	outputs[| 0] = nodeValue("Color", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, c_white);
	
	input_display_list = [ 3, 0, 1, 2 ];
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var nor = _data[3];
		
		return make_color_hsv(
				nor? _data[0] * 255 : _data[0] / 360 * 255, 
				nor? _data[1] * 255 : _data[1], 
				nor? _data[2] * 255 : _data[2]
			);
	}
	
	static onValueUpdate = function(index = 0) {
		if(index == 3) {
			var _nor = inputs[| 3].getValue();
			
			if(_nor) {
				inputs[| 0].type = VALUE_TYPE.integer;
				inputs[| 0].setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
				
				inputs[| 1].type = VALUE_TYPE.integer;
				inputs[| 1].setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
				
				inputs[| 2].type = VALUE_TYPE.integer;
				inputs[| 2].setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
			} else {
				inputs[| 0].type = VALUE_TYPE.integer;
				inputs[| 0].setDisplay(VALUE_DISPLAY.slider, [0, 360, 1]);
				
				inputs[| 1].type = VALUE_TYPE.integer;
				inputs[| 1].setDisplay(VALUE_DISPLAY.slider, [0, 255, 1]);
				
				inputs[| 2].type = VALUE_TYPE.integer;
				inputs[| 2].setDisplay(VALUE_DISPLAY.slider, [0, 255, 1]);
			}
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
	
	static doApplyDeserialize = function() {
		onValueUpdate(3);
	}
}