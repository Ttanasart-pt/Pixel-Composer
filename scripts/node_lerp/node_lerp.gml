function Node_Lerp(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "Lerp";
	color		= COLORS.node_blend_number;
	
	setDimension(96, 48);
	
	inputs[| 0] = nodeValue_Float("a", self, 0);
	inputs[| 1] = nodeValue_Float("b", self, 0);
	inputs[| 2] = nodeValue_Slider_Range("Progress", self, 0);
	
	outputs[| 0] = nodeValue_Output("Result", self, VALUE_TYPE.float, 0);
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { 
		return lerp(_data[0], _data[1], _data[2]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str = "lerp";
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}