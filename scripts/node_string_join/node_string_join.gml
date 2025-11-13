function Node_String_Join(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Join Text Array";
	always_pad = true;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Text("Text array", []))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Text("Divider"))
		.rejectArray();
		
	inputs[1].editWidget.format = TEXT_AREA_FORMAT.delimiter;
	
	newOutput(0, nodeValue_Output("Text", VALUE_TYPE.text, ""));
	
	static update = function() { 
		var _arr = getInputData(0);
		var _div = getInputData(1);
		var str = "";
		
		for( var i = 0, n = array_length(_arr); i < n; i++ ) 
			str += (i? _div : "")  + string(_arr[i]);
		
		outputs[0].setValue(str);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var str  = outputs[0].getValue();
		var bbox = draw_bbox;
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}