function Node_String(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Text";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Text("Text"));
	
	newOutput(0, nodeValue_Output("Text", VALUE_TYPE.text, ""));
	
	static processData = function(_output, _data, _index = 0) { 
		return string(_data[0]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var str  = getInputData(0);
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}