function Node_Random(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "Random";
	color		= COLORS.node_blend_number;
	
	setDimension(96, 80);
	
	inputs[| 0] = nodeValue("seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, irandom(99999));
	
	inputs[| 1] = nodeValue("from", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 2] = nodeValue("to", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	outputs[| 0] = nodeValue("Result", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		random_set_seed(_data[0]);
		return random_range(_data[1], _data[2]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str = outputs[| 0].getValue();
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}