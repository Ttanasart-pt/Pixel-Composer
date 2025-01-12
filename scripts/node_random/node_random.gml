function Node_Random(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "Random";
	color		= COLORS.node_blend_number;
	
	setDimension(96, 48);
	
	newInput(0, nodeValue_Int("Seed", self, irandom(99999)));
	
	newInput(1, nodeValue_Float("From", self, 0));
	
	newInput(2, nodeValue_Float("To", self, 1));
	
	newInput(3, nodeValue_Bool("Shuffle", self, false));
	
	newOutput(0, nodeValue_Output("Result", self, VALUE_TYPE.float, 0));
	
	static processData_prebatch  = function() {
		var _shuffle = getSingleValue(3);
		update_on_frame = _shuffle;
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {
		random_set_seed(_data[0] + _data[3] * CURRENT_FRAME * pi);
		return random_range(_data[1], _data[2]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str = outputs[0].getValue();
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}