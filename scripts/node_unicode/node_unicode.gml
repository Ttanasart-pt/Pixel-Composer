function Node_Unicode(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Unicode";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	
	
	inputs[| 0] = nodeValue("Unicode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 64);
	
	outputs[| 0] = nodeValue("Character", self, JUNCTION_CONNECT.output, VALUE_TYPE.text, 0);
	
	static process_data = function(_output, _data, index = 0) { 
		return chr(_data[0]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var str = outputs[| 0].getValue();
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}