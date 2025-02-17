function Node_String_Change_Case(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Change Case";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Text("Text", self, ""))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Enum_Scroll("Target", self, 0, [ "Lowercase", "Uppercase", "Titlecase" ]))
	
	newOutput(0, nodeValue_Output("Text", self, VALUE_TYPE.text, ""));
	
	static processData = function(_output, _data, _index = 0) { 
	    switch(_data[1]) {
	        case 0 : return string_lower(_data[0]);
	        case 1 : return string_upper(_data[0]);
	        case 2 : return string_titlecase(_data[0]);
	    }
	    
	    return _data[0]; 
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var str = outputs[0].getValue();
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}