function Node_String_Merge(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Combine Text";
	previewable   = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Text A", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
	
	inputs[| 1] = nodeValue("Text B", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
	
	outputs[| 0] = nodeValue("Text", self, JUNCTION_CONNECT.output, VALUE_TYPE.text, "");
	
	static processData = function(_output, _data, _index = 0) { 
		return string(_data[0]) + string(_data[1]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var str = getInputData(0);
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}