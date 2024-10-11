function Node_String_Split(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Split Text";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Text("Text", self, ""))
		.setVisible(true, true);
		
	newInput(1, nodeValue_Text("Delimiter", self, " ", "Character that used to split text,\nleave blank to create character array."));
	inputs[1].editWidget.format = TEXT_AREA_FORMAT.delimiter;
	
	newOutput(0, nodeValue_Output("Text", self, VALUE_TYPE.text, ""));
	
	static processData = function(_output, _data, _index = 0) { 
		if(_data[1] == "") 
			return string_to_array(_data[0]);
			
		var delim = _data[1];
		delim = string_replace_all(delim, "\\n", "\n");
		delim = string_replace_all(delim, "\\t", "\t");
		return string_splice(_data[0], delim);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var str  = getInputData(1);
		var bbox = drawGetBbox(xx, yy, _s);
		var cx   = bbox.xc;
		var cy   = bbox.yc;
		
		if(string_length(str) == 0) {
			draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_bbox(bbox, __txt("None"));
			return;
		}
		
		_s *= 0.5;
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		str = string_cut(str, bbox.w - _s * 32, "...", _s);
		draw_text_add(cx, cy, str, _s);
		
		var ww = (string_width(str) / 2) * _s;
		draw_set_text(f_sdf, fa_right, fa_center, COLORS._main_text_sub);
		draw_text_transformed(cx - ww, cy, "|", _s, _s, 0);
		
		draw_set_halign(fa_left);
		draw_text_transformed(cx + ww, cy, "|", _s, _s, 0);
	}
}