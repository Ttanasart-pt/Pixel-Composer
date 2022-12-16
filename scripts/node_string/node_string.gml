function Node_String(_x, _y, _group = -1) : Node_Value_Processor(_x, _y, _group) constructor {
	name = "Text";
	previewable   = false;
	
	w = 96;
	min_h = 0;
	
	inputs[| 0] = nodeValue(0, "Text", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
	outputs[| 0] = nodeValue(0, "Text", self, JUNCTION_CONNECT.output, VALUE_TYPE.text, "");
	
	function process_value_data(_data) { 
		return _data[0];
	}
	
	doUpdate();
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var str = inputs[| 0].getValue();
		draw_text_cut(xx + w / 2 * _s, yy + 10 + h / 2 * _s, str, w - ui(6));
	}
}