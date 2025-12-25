function Node_Color_RGB(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "RGB Color";
	setDimension(96, 48);
	
	newInput( 3, nodeValue_Bool(   "Normalized", 1 ));
	newInput( 0, nodeValue_Slider( "Red",   1 )).setVisible(true, true);
	newInput( 1, nodeValue_Slider( "Green", 1 )).setVisible(true, true);
	newInput( 2, nodeValue_Slider( "Blue",  1 )).setVisible(true, true);
	newInput( 4, nodeValue_Slider( "Alpha", 1 ));
	// 5
	
	newOutput(0, nodeValue_Output("Color", VALUE_TYPE.color, c_white));
	
	input_display_list = [ 3, 0, 1, 2, 4 ];
	
	////- Node
	
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
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var nor = _data[3];
			
			var rr  = _data[0];
			var gg  = _data[1];
			var bb  = _data[2];
			var aa  = _data[4];
		#endregion
		
		return make_color_rgba(
					clamp(nor? rr * 255 : rr, 0, 255),
					clamp(nor? gg * 255 : gg, 0, 255),
					clamp(nor? bb * 255 : bb, 0, 255),
					clamp(nor? aa * 255 : aa, 0, 255),
				);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
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