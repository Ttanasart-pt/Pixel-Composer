function Node_Color_RGB(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name		= "RGB Color";
	previewable = false;
	
	w = 96;
	min_h = 0;
	
	inputs[| 0] = nodeValue(0, "Red", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01])
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue(1, "Green", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01])
		.setVisible(true, true);
	
	inputs[| 2] = nodeValue(2, "Blue", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01])
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue(0, "Color", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, c_white);
	
	static update = function() { 
		outputs[| 0].setValue(make_color_rgb(inputs[| 0].getValue() * 255, inputs[| 1].getValue() * 255, inputs[| 2].getValue() * 255));
	}
	doUpdate();
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var x0 = xx + 8 * _s;
		var x1 = xx + (w - 8) * _s;
		var y0 = yy + 20 + 8 * _s;
		var y1 = yy + (h - 8) * _s;
		
		if(y1 > y0) {
			draw_set_color(outputs[| 0].getValue());
			draw_rectangle(x0, y0, x1, y1, 0);
		}
	}
}