function Node_String_Join(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Join Text";
	previewable   = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Text array", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, [])
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Divider", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "")
		.rejectArray();
	inputs[| 1].editWidget.format = TEXT_AREA_FORMAT.delimiter;
	
	outputs[| 0] = nodeValue("Text", self, JUNCTION_CONNECT.output, VALUE_TYPE.text, "");
	
	function update() { 
		var _arr = inputs[| 0].getValue();
		var _div = inputs[| 1].getValue();
		var str = "";
		
		for( var i = 0; i < array_length(_arr); i++ ) 
			str += (i? _div : "")  + string(_arr[i]);
		
		outputs[| 0].setValue(str);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var str  = outputs[| 0].getValue();
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	 = string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}