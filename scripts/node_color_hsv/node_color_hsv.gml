function Node_Color_HSV(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "HSV Color";
	setDimension(96, 48);
	
	inputs[| 0] = nodeValue("Hue", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Saturation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider)
		.setVisible(true, true);
	
	inputs[| 2] = nodeValue("Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider)
		.setVisible(true, true);
	
	inputs[| 3] = nodeValue("Normalized", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, 1);
	
	inputs[| 4] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	outputs[| 0] = nodeValue("Color", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, c_white);
	
	input_display_list = [ 3, 0, 1, 2, 4 ];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var nor = _data[3];
		
		return make_color_hsva(
				nor? _data[0] * 255 : _data[0], 
				nor? _data[1] * 255 : _data[1], 
				nor? _data[2] * 255 : _data[2],
				nor? _data[4] * 255 : _data[4],
			);
	} #endregion
	
	static onValueUpdate = function(index = 0) { #region
		if(index == 3) {
			var _nor = getInputData(3);
			
			if(_nor) {
				inputs[| 0].setType(VALUE_TYPE.float);
				inputs[| 0].setDisplay(VALUE_DISPLAY.slider);
				
				inputs[| 1].setType(VALUE_TYPE.float);
				inputs[| 1].setDisplay(VALUE_DISPLAY.slider);
				
				inputs[| 2].setType(VALUE_TYPE.float);
				inputs[| 2].setDisplay(VALUE_DISPLAY.slider);
				
				inputs[| 4].setType(VALUE_TYPE.float);
				inputs[| 4].setDisplay(VALUE_DISPLAY.slider);
			} else {
				inputs[| 0].setType(VALUE_TYPE.integer);
				inputs[| 0].setDisplay(VALUE_DISPLAY.slider, { range: [0, 255, 0.1] });
				
				inputs[| 1].setType(VALUE_TYPE.integer);
				inputs[| 1].setDisplay(VALUE_DISPLAY.slider, { range: [0, 255, 0.1] });
				
				inputs[| 2].setType(VALUE_TYPE.integer);
				inputs[| 2].setDisplay(VALUE_DISPLAY.slider, { range: [0, 255, 0.1] });
				
				inputs[| 4].setType(VALUE_TYPE.integer);
				inputs[| 4].setDisplay(VALUE_DISPLAY.slider, { range: [0, 255, 0.1] });
			}
		}
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var col = outputs[| 0].getValue();
		
		if(is_array(col)) {
			drawPalette(col, bbox.x0, bbox.y0, bbox.w, bbox.h);
			return;
		}
		
		drawColor(col, bbox.x0, bbox.y0, bbox.w, bbox.h);
	} #endregion
	
	static doApplyDeserialize = function() { #region
		onValueUpdate(3);
	} #endregion
}