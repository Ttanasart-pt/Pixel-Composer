function Node_Boolean(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Boolean";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	min_h = 32 + 24 * 1;
	
	inputs[| 0] = nodeValue("Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Boolean", self, JUNCTION_CONNECT.output, VALUE_TYPE.boolean, false);
	
	function process_data(_output, _data, _output_index, _array_index = 0) {  
		return _data[0]; 
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var str	= inputs[| 0].getValue()? get_text("true", "True") : get_text("false", "False");
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}
