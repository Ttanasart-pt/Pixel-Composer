function Node_String_Merge(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Combine Text";
	
	setDimension(96, 48);
	
	outputs[0] = nodeValue_Output("Text", self, VALUE_TYPE.text, "");
	
	static createNewInput = function() {
		var index = array_length(inputs);
		
		inputs[index] = nodeValue_Text("Text", self, "" )
			.setVisible(true, true);
		
		return inputs[index];
	} setDynamicInput(1, true, VALUE_TYPE.text);
	
	static processData = function(_output, _data, _index = 0) { 
		var _str = "";
		for( var i = 0, n = array_length(_data); i < n; i++ ) 
			_str += _data[i];
		
		return _str;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var _str = outputs[0].getValue();
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, _str);
	}
}