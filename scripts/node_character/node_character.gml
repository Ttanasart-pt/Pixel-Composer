function Node_Unicode(_x, _y) : Node_Value_Processor(_x, _y) constructor {
	name = "Unicode";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	min_h = 0;
	
	inputs[| 0] = nodeValue(0, "Unicode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 64);
	
	outputs[| 0] = nodeValue(0, "Character", self, JUNCTION_CONNECT.output, VALUE_TYPE.text, 0);
	
	function process_value_data(_data, index = 0) { 
		return chr(_data[0]);
	}
	
	doUpdate();
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		draw_text(xx + w / 2 * _s, yy + 10 + h / 2 * _s, chr(inputs[| 0].getValue()));
	}
}