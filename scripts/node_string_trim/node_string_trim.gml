function Node_String_Trim(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Trim Text";
	
	setDimension(96, 48);
	
	inputs[| 0] = nodeValue("Text", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "")
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Head", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	inputs[| 2] = nodeValue("Tail", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	inputs[| 3] = nodeValue_Enum_Scroll("Trim", self,  0, ["Character", "Word"]);
	
	inputs[| 4] = nodeValue_Enum_Scroll("Mode", self,  0, ["Counter", "Progress"])
		.setTooltip("Set to progress to use ratio, where 0 means no change and 1 means the entire length of the text.");
	
	outputs[| 0] = nodeValue("Text", self, JUNCTION_CONNECT.output, VALUE_TYPE.text, "");
	
	input_display_list = [
		["Text",	false], 0,
		["Trim",	false], 3, 4, 1, 2,
	];
	
	static step = function() {
		var mode = getInputData(4);
		
		inputs[| 1].setType(mode? VALUE_TYPE.float : VALUE_TYPE.integer);
		inputs[| 2].setType(mode? VALUE_TYPE.float : VALUE_TYPE.integer);
	}
	
	static processData = function(_output, _data, _index = 0) { 
		var str = _data[0];
		var hed = max(0, _data[1]);
		var tal = max(0, _data[2]);
		
		var trim = _data[3];
		var mode = _data[4];
		
		var _str = str;
		
		if(trim == 0) {
			if(mode == 0)
				_str = string_copy(str, 1 + hed, string_length(str) - hed - tal);
			else if(mode == 1) {
				var h = hed * string_length(str);
				var t = tal * string_length(str);
				
				_str = string_copy(str, 1 + h, string_length(str) - hed - t);
			}
		} else if(trim == 1) {
			var w = string_splice(str, " ");
			_str = "";
			
			if(mode == 1) {
				hed *= array_length(w);
				tal *= array_length(w);
			}
			
			for( var i = hed; i < array_length(w) - tal; i++ )
				_str += (i == hed? "" : " ") + w[i];
		}
		
		return _str;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var str = outputs[| 0].getValue();
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}