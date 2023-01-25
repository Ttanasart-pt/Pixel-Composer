function Node_String_Split(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Split Text";
	previewable   = false;
	
	w = 96;
	
	
	inputs[| 0] = nodeValue(0, "Text", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "")
		.setVisible(true, true);
	inputs[| 1] = nodeValue(1, "Delimiter", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, " ", "Character that used to split text,\nleave blank to create character array.");
	
	outputs[| 0] = nodeValue(0, "Text", self, JUNCTION_CONNECT.output, VALUE_TYPE.text, "");
	
	function process_data(_output, _data, _index = 0) { 
		if(_data[1] == "") 
			return string_to_array(_data[0]);
			
		var delim = _data[1];
		delim = string_replace_all(delim, "\\n", "\n");
		delim = string_replace_all(delim, "\\t", "\t");
		return string_splice(_data[0], delim);
	}
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
		var str = inputs[| 1].getValue();
		var bbox = drawGetBbox(xx, yy, _s);
		var cx = bbox.xc;
		var cy = bbox.yc;
		
		if(string_length(str) == 0) {
			draw_set_text(f_p0b, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_cut(cx, cy, "None", w - ui(6), _s);
			return;
		}
		
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		draw_text_cut(cx, cy, str, bbox.w, _s);
		
		var ww = (string_width(str) / 2) * _s;
		draw_set_text(f_h5, fa_right, fa_center, COLORS._main_text_sub);
		draw_text_transformed(cx - ww, cy, "|", _s, _s, 0);
		
		draw_set_halign(fa_left);
		draw_text_transformed(cx + ww, cy, "|", _s, _s, 0);
	}
}