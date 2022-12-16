function Node_String_Split(_x, _y, _group = -1) : Node_Value_Processor(_x, _y, _group) constructor {
	name = "Text split";
	previewable   = false;
	
	w = 96;
	min_h = 0;
	
	inputs[| 0] = nodeValue(0, "Text", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "")
		.setVisible(true, true);
	inputs[| 1] = nodeValue(1, "Delimiter", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, " ");
	
	outputs[| 0] = nodeValue(0, "Text", self, JUNCTION_CONNECT.output, VALUE_TYPE.text, "");
	
	function process_value_data(_data) { 
		return string_splice(_data[0], _data[1]);
	}
	
	doUpdate();
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
		var cx = xx + w * _s / 2;
		var cy = yy + 10 + (h - 10) * _s / 2;
		draw_sprite_uniform(s_node_text_splice, 0, cx, cy, _s);
	}
}