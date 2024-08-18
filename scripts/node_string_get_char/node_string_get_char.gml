function Node_String_Get_Char(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Get Character";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Text("Text", self, ""))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Int("Index", self, 1));
	
	newInput(2, nodeValue_Int("Amount", self, 1));
	
	outputs[0] = nodeValue_Output("Text", self, VALUE_TYPE.text, "");
	
	static processData = function(_output, _data, _index = 0) {
		return string_copy(_data[0], _data[1], _data[2]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var str  = getInputData(0);
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}