function Node_Struct_JSON_Parse(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "JSON Parse";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Text("JSON string"))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Struct", VALUE_TYPE.struct, {} ));
	
	static update = function(frame = CURRENT_FRAME) {
		var _str = getInputData(0);
		var str  = json_try_parse(_str);
		outputs[0].setValue(str);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, "JSON");
	}
}