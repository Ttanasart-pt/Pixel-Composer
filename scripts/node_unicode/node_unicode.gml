function Node_Unicode(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Unicode";
	color = COLORS.node_blend_number;
	always_pad = true;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Int("Unicode", 64));
	
	newOutput(0, nodeValue_Output("Character", VALUE_TYPE.text, 0));
	
	static processData = function(_output, _data, index = 0) { 
		return chr(_data[0]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		var str  = outputs[0].getValue();
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}