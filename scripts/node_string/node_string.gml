function Node_String(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Text";
	previewable   = false;
	
	w = 96;
	min_h = 0;
	
	inputs[| 0] = nodeValue(0, "Text", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
	outputs[| 0] = nodeValue(0, "Text", self, JUNCTION_CONNECT.output, VALUE_TYPE.text, "");
	
	function process_data(_output, _data, _index = 0) { 
		return _data[0];
	}
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var cx = xx + w / 2 * _s;
		var cy = yy + 10 + h / 2 * _s;
		
		var str = inputs[| 0].getValue();
		var ss = min((w - 8) * _s / string_width(str), (h - 24) * _s / string_height(str));
		
		draw_text_transformed(cx, cy, str, ss, ss, 0);
	}
}