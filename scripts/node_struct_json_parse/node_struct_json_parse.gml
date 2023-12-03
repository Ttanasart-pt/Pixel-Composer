function Node_Struct_JSON_Parse(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "JSON Parse";
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	inputs[| 0] = nodeValue("JSON string", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, 0)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Struct", self, JUNCTION_CONNECT.output, VALUE_TYPE.struct, {} );
	
	static update = function(frame = CURRENT_FRAME) {
		var _str = getInputData(0);
		var str  = json_parse(_str);
		outputs[| 0].setValue(str);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, "JSON");
	}
}