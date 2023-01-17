function Node_Random(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name		= "Random";
	color		= COLORS.node_blend_number;
	previewable = false;
	
	w = 96;
	
	
	inputs[| 0] = nodeValue(0, "seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, irandom(99999));
	inputs[| 1] = nodeValue(1, "from", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	inputs[| 2] = nodeValue(2, "to", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	outputs[| 0] = nodeValue(0, "Result", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	function process_data(_output, _data, index = 0) { 
		random_set_seed(_data[0]);
		return random_range(_data[1], _data[2]);
	}
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var str = outputs[| 0].getValue();
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}