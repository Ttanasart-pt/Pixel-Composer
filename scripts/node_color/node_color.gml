function Node_Color(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name		= "Color";
	previewable = false;
	
	
	w = 96;
	
	inputs[| 0] = nodeValue(0, "Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	outputs[| 0] = nodeValue(0, "Color", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, []);
	
	static update = function() {
		outputs[| 0].setValue(inputs[| 0].getValue());
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		draw_set_color(inputs[| 0].getValue());
		draw_rectangle(bbox.x0, bbox.y0, bbox.x1, bbox.y1, 0);
	}
}