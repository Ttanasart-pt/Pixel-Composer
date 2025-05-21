function Node_Color_HSV(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "HSV Color";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Float("Hue", 1))
		.setDisplay(VALUE_DISPLAY.slider)
		.setVisible(true, true);
	
	newInput(1, nodeValue_Float("Saturation", 1))
		.setDisplay(VALUE_DISPLAY.slider)
		.setVisible(true, true);
	
	newInput(2, nodeValue_Float("Value", 1))
		.setDisplay(VALUE_DISPLAY.slider)
		.setVisible(true, true);
	
	newInput(3, nodeValue_Bool("Normalized", 1));
	
	newInput(4, nodeValue_Float("Alpha", 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newOutput(0, nodeValue_Output("Color", VALUE_TYPE.color, c_white));
	
	input_display_list = [ 3, 0, 1, 2, 4 ];
	
	static processData = function(_outSurf, _data, _array_index) {
		var nor = _data[3];
		
		return make_color_hsva(
				nor? clamp(_data[0], 0, 1) * 255 : clamp(_data[0], 0, 1),
				nor? clamp(_data[1], 0, 1) * 255 : clamp(_data[1], 0, 1),
				nor? clamp(_data[2], 0, 1) * 255 : clamp(_data[2], 0, 1),
				nor? clamp(_data[4], 0, 1) * 255 : clamp(_data[4], 0, 1),
			);
	}
	
	static onValueUpdate = function(index = 0) {
		if(index == 3) {
			var _nor = getInputData(3);
			
			if(_nor) {
				inputs[0].setType(VALUE_TYPE.float);
				inputs[0].setDisplay(VALUE_DISPLAY.slider);
				
				inputs[1].setType(VALUE_TYPE.float);
				inputs[1].setDisplay(VALUE_DISPLAY.slider);
				
				inputs[2].setType(VALUE_TYPE.float);
				inputs[2].setDisplay(VALUE_DISPLAY.slider);
				
				inputs[4].setType(VALUE_TYPE.float);
				inputs[4].setDisplay(VALUE_DISPLAY.slider);
			} else {
				inputs[0].setType(VALUE_TYPE.integer);
				inputs[0].setDisplay(VALUE_DISPLAY.slider, { range: [0, 255, 0.1] });
				
				inputs[1].setType(VALUE_TYPE.integer);
				inputs[1].setDisplay(VALUE_DISPLAY.slider, { range: [0, 255, 0.1] });
				
				inputs[2].setType(VALUE_TYPE.integer);
				inputs[2].setDisplay(VALUE_DISPLAY.slider, { range: [0, 255, 0.1] });
				
				inputs[4].setType(VALUE_TYPE.integer);
				inputs[4].setDisplay(VALUE_DISPLAY.slider, { range: [0, 255, 0.1] });
			}
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var col = outputs[0].getValue();
		
		if(is_array(col)) {
			drawPalette(col, bbox.x0, bbox.y0, bbox.w, bbox.h);
			return;
		}
		
		drawColor(col, bbox.x0, bbox.y0, bbox.w, bbox.h);
	}
	
	static postApplyDeserialize = function() {
		onValueUpdate(3);
	}
}