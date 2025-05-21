function Node_String_Count(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Count Text";
	
	setDimension(96, 48);
	
	newInput(0, nodeValue_Text("Text"))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Text("Count Text"))
	
	newOutput(0, nodeValue_Output("Amount", VALUE_TYPE.integer, 0));
	
	static processData = function(_output, _data, _index = 0) {  return string_count(_data[1], _data[0]); }
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var str = inputs[0].getValue();
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}