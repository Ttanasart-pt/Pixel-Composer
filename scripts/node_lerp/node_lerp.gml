function Node_Lerp(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "Lerp";
	color		= COLORS.node_blend_number;
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("a", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	inputs[| 1] = nodeValue("b", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	inputs[| 2] = nodeValue("Progress", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider_range, [0, 1, .01]);
	
	outputs[| 0] = nodeValue("Result", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { 
		return lerp(_data[0], _data[1], _data[2]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var str = "lerp";
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}