function Node_String_Regex_Match(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "RegEx Match";
	
	setDimension(96, 48);
	
	inputs[| 0] = nodeValue_Text("Text", self, "")
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue_Text("Regex", self, "");
	
	outputs[| 0] = nodeValue_Output("Results", self, VALUE_TYPE.boolean, false);
	
	input_display_list = [
		0, 1,
	];
	
	static processData = function(_output, _data, _index = 0) { 
		var str = _data[0];
		var reg = _data[1];
		
		return RegexMatch(str, reg);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var str  = getInputData(0);
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}