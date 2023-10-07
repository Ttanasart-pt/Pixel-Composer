function Node_Color_RGB(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "RGB Color";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Red", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Green", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider)
		.setVisible(true, true);
	
	inputs[| 2] = nodeValue("Blue", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider)
		.setVisible(true, true);
	
	inputs[| 3] = nodeValue("Normalized", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, 1);
	
	outputs[| 0] = nodeValue("Color", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, c_white);
	
	input_display_list = [ 3, 0, 1, 2 ];
	
	static onValueUpdate = function(index = 0) {
		if(index == 3) {
			var _nor = getInputData(3);
			
			if(_nor) {
				inputs[| 0].setType(VALUE_TYPE.float);
				inputs[| 0].setDisplay(VALUE_DISPLAY.slider);
				
				inputs[| 1].setType(VALUE_TYPE.float);
				inputs[| 1].setDisplay(VALUE_DISPLAY.slider);
				
				inputs[| 2].setType(VALUE_TYPE.float);
				inputs[| 2].setDisplay(VALUE_DISPLAY.slider);
			} else {
				inputs[| 0].setType(VALUE_TYPE.integer);
				inputs[| 0].setDisplay(VALUE_DISPLAY.slider, { range: [0, 255, 1] });
				
				inputs[| 1].setType(VALUE_TYPE.integer);
				inputs[| 1].setDisplay(VALUE_DISPLAY.slider, { range: [0, 255, 1] });
				
				inputs[| 2].setType(VALUE_TYPE.integer);
				inputs[| 2].setDisplay(VALUE_DISPLAY.slider, { range: [0, 255, 1] });
			}
		}
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var nor = _data[3];
		if(!is_real(_data[0])) return 0;
		if(!is_real(_data[1])) return 0;
		if(!is_real(_data[2])) return 0;
		
		return make_color_rgb(
					nor? _data[0] * 255 : _data[0], 
					nor? _data[1] * 255 : _data[1], 
					nor? _data[2] * 255 : _data[2]
				);
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