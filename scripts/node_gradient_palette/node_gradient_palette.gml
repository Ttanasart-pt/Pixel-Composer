function Node_Gradient_Palette(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "Gradient Palette";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Palette", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, [ c_black ] )
		.setDisplay(VALUE_DISPLAY.palette)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Custom positions", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 2] = nodeValue("Positions", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [], "Array of number indicating color position (0 - 1).")
		.setVisible(true, true);
	inputs[| 2].array_depth = 1;
	
	inputs[| 3] = nodeValue("Blending", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "RGB", "HSV", "Hard" ]);
	
	outputs[| 0] = nodeValue("Gradient", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, new gradientObject(c_white) )
		.setDisplay(VALUE_DISPLAY.gradient);
	
	_pal = -1;
	
	static step = function() {
		var usePos = array_safe_get(current_data, 1);
		inputs[| 2].setVisible(usePos, usePos);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var pal     = _data[0];
		var pos_use = _data[1];
		var _pos    = _data[2];
		var type    = _data[3];
		
		var grad    = new gradientObject();
		grad.keys   = [];
		
		for( var i = 0; i < array_length(pal); i++ ) {
			var clr = pal[i];
			var pos = pos_use? array_safe_get(_pos, i, 0) : i / array_length(pal);
			
			grad.keys[i] = new gradientKey(pos, clr);
		}
		switch(type) {
			case 0 : grad.type = GRADIENT_INTER.smooth; break;
			case 1 : grad.type = GRADIENT_INTER.hue;	break;
			case 2 : grad.type = GRADIENT_INTER.none;	break;
		}
		
		return grad;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var grad = outputs[| 0].getValue();
		if(is_array(grad)) {
			if(array_length(grad) == 0) return;
			grad = grad[0];
		}
		
		grad.draw(bbox.x0, bbox.y0, bbox.w, bbox.h);
	}
}