function Node_String_Get_Char(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Get Character";
	w = 96;
	
	inputs[| 0] = nodeValue("Text", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "")
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Index", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
	
	inputs[| 2] = nodeValue("Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
	
	outputs[| 0] = nodeValue("Text", self, JUNCTION_CONNECT.output, VALUE_TYPE.text, "");
	
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