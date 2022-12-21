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
		if(_data[1] == "") 
			return string_to_array(_data[0]);
		return string_splice(_data[0], _data[1]);
	}
	
	doUpdate();
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
		var str = inputs[| 1].getValue();
		var cx = xx + w / 2 * _s;
		var cy = yy + 10 + h / 2 * _s;
		
		if(string_length(str) == 0) {
			draw_set_text(f_p0b, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_cut(cx, cy, "None", w - ui(6), _s);
			return;
		}
		
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		draw_text_cut(cx, cy, str, w - ui(6), _s);
		
		var ww = (string_width(str) / 2) * _s;
		draw_set_text(f_h5, fa_right, fa_center, COLORS._main_text_sub);
		draw_text_transformed(cx - ww, cy, "|", _s, _s, 0);
		
		draw_set_halign(fa_left);
		draw_text_transformed(cx + ww, cy, "|", _s, _s, 0);
	}
}