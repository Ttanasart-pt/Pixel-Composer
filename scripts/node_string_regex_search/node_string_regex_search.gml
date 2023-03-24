function Node_String_Regex_Search(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "RegEx Search";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Text", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "")
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Regex", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
	
	outputs[| 0] = nodeValue("Results", self, JUNCTION_CONNECT.output, VALUE_TYPE.text, "");
	
	input_display_list = [
		["Text",	false], 0,
		["RegEx",	false], 1,
	];
	
	function step() {
		var mode = inputs[| 4].getValue();
	}
	
	function process_data(_output, _data, _index = 0) { 
		var str = _data[0];
		return str;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var str = outputs[| 0].getValue();
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}