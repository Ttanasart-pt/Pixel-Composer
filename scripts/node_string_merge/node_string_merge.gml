function Node_String_Merge(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Combine Text";
	previewable   = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue(0, "Text A", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
	
	inputs[| 1] = nodeValue(1, "Text B", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
	
	outputs[| 0] = nodeValue(0, "Text", self, JUNCTION_CONNECT.output, VALUE_TYPE.text, "");
	
	function process_data(_output, _data, _index = 0) { 
		return string(_data[0]) + string(_data[1]);
	}
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var str = inputs[| 0].getValue();
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}