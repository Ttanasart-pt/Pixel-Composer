function Node_Color_HSV(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name		= "HSV Color";
	previewable = false;
	
	w = 96;
	
	
	inputs[| 0] = nodeValue(0, "Hue", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01])
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue(1, "Saturation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01])
		.setVisible(true, true);
	
	inputs[| 2] = nodeValue(2, "Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01])
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue(0, "Color", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, c_white);
	
	static update = function() { 
		outputs[| 0].setValue(make_color_hsv(inputs[| 0].getValue() * 255, inputs[| 1].getValue() * 255, inputs[| 2].getValue() * 255));
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		draw_set_color(outputs[| 0].getValue());
		draw_rectangle(bbox.x0, bbox.y0, bbox.x1, bbox.y1, 0);
	}
}