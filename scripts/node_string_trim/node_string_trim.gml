function Node_String_Trim(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Trim Text";
	previewable = false;
	
	w = 96;
	
	
	inputs[| 0] = nodeValue("Text", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "")
		.setVisible(true, true);
	inputs[| 1] = nodeValue("Head", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	inputs[| 2] = nodeValue("Tail", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	outputs[| 0] = nodeValue("Text", self, JUNCTION_CONNECT.output, VALUE_TYPE.text, "");
	
	function process_data(_output, _data, _index = 0) { 
		var str = _data[0];
		str = string_copy(str, 1 + _data[1], string_length(str) - _data[1] - _data[2]);
		
		return str;
	}
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
		var str = inputs[| 1].getValue();
		if(is_array(str) && array_length(str)) 
			str = str[0];
		
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}