function Node_String_Length(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Text Length";
	
	setDimension(96, 48);
	
	newInput(0, nodeValue_Text("Text", self, ""))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Enum_Scroll("Mode", self,  0, ["Character", "Word"]));
	
	newOutput(0, nodeValue_Output("Text", self, VALUE_TYPE.text, ""));
	
	static processData = function(_output, _data, _index = 0) { 
		if(_data[1] == 0)	return string_length(_data[0]);
		else				return array_length(string_splice(_data[0], " "));
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var str = outputs[0].getValue();
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}