function Node_Unicode(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Unicode";
	color = COLORS.node_blend_number;
	
	setDimension(96, 48);
	
	
	newInput(0, nodeValue_Int("Unicode", self, 64));
	
	newOutput(0, nodeValue_Output("Character", self, VALUE_TYPE.text, 0));
	
	static processData = function(_output, _data, index = 0) { 
		return chr(_data[0]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var str = outputs[0].getValue();
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}