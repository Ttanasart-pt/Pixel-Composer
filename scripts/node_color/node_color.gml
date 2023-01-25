function Node_Color(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name		= "Color";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue(0, "Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	outputs[| 0] = nodeValue(0, "Color", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, c_white);
	
	function process_data(_output, _data, index = 0) { 
		return _data[0];
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var col = inputs[| 0].getValue();
		
		if(is_array(col)) return;
		
		draw_set_color(col);
		draw_rectangle(bbox.x0, bbox.y0, bbox.x1, bbox.y1, 0);
	}
}