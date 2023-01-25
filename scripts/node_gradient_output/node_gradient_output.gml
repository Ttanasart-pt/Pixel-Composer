function Node_Gradient_Out(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name		= "Gradient";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue(0, "Gradient", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white)
		.setDisplay(VALUE_DISPLAY.gradient);
	
	inputs[| 1] = nodeValue(1, "Sample", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0, "Position to sample a color from the gradient.")
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01])
		.rejectArray();
	
	outputs[| 0] = nodeValue(0, "Gradient", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, [])
		.setDisplay(VALUE_DISPLAY.gradient);
	
	outputs[| 1] = nodeValue(1, "Color", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, c_white);
	
	_pal = -1;
	static update = function() {
		var pal = inputs[| 0].getValue();
		var pos = inputs[| 1].getValue();
		
		outputs[| 0].setValue(pal);
		outputs[| 1].setValue(gradient_eval(pal, pos));
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		draw_gradient(bbox.x0, bbox.y0, bbox.w, bbox.h, inputs[| 0].getValue(), inputs[| 0].extra_data[| 0]);
	}
}