function Node_String_Replace(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Replace Text";
	setDimension(96, 48);
	
	////- =Text
	newInput(0, nodeValue_Text( "Text"    )).setVisible(true, true);
	newInput(1, nodeValue_Text( "Find"    ));
	newInput(2, nodeValue_Text( "Replace" ));
	
	////- =Amount
	newInput(3, nodeValue_Bool( "All", true ));
	
	newOutput(0, nodeValue_Output("Results", VALUE_TYPE.text, ""));
	
	input_display_list = [
		[ "Text",   false ], 0, 1, 2, 3, 
	];
	
	static processData = function(_output, _data, _index = 0) { 
		var _str = _data[0];
		var _fin = _data[1];
		var _rep = _data[2];
		
		var _all = _data[3];
		
		if(_all) return string_replace_all(_str, _fin, _rep);
		return string_replace(_str, _fin, _rep);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var str  = outputs[0].getValue();
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}