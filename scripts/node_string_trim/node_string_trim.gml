function Node_String_Trim(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Trim Text";
	always_pad = true;
	setDimension(96, 48);
	
	////- =Text
	newInput(0, nodeValue_Text( "Text"    )).setVisible(true, true);
	
	////- =Trim
	newInput(3, nodeValue_EScroll( "Trim", 0, [ "Character", "Word", "White-Space" ] ));
	newInput(4, nodeValue_EScroll( "Mode", 0, [ "Counter", "Progress" ] )).setTooltip("Set to progress to use ratio, where 0 means no change and 1 means the entire length of the text.");
	newInput(1, nodeValue_Int(     "Head", 0  ));
	newInput(2, nodeValue_Int(     "Tail", 0  ));
	newInput(5, nodeValue_Text(    "Text", "" ));
	// 6
	
	newOutput(0, nodeValue_Output("Text", VALUE_TYPE.text, ""));
	
	input_display_list = [
		[ "Text", false ], 0,
		[ "Trim", false ], 3, 4, 1, 2,  5, 
	];
	
	////- Node
	
	static processData = function(_output, _data, _index = 0) { 
		#region data
			var str = _data[0];
			var hed = max(0, _data[1]);
			var tal = max(0, _data[2]);
			
			var trim = _data[3];
			var mode = _data[4];
			var text = _data[5];
			
			inputs[4].setVisible(trim != 2);
			inputs[1].setVisible(trim != 2);
			inputs[2].setVisible(trim != 2);
			inputs[5].setVisible(trim == 2);
			
			inputs[1].setType(mode? VALUE_TYPE.float : VALUE_TYPE.integer);
			inputs[2].setType(mode? VALUE_TYPE.float : VALUE_TYPE.integer);
		#endregion
		
		var _str = str;
		
		switch(trim) {
			case 0 :
				if(mode == 0)
					_str = string_copy(str, 1 + hed, string_length(str) - hed - tal);
					
				else if(mode == 1) {
					var h = hed * string_length(str);
					var t = tal * string_length(str);
					
					_str = string_copy(str, 1 + h, string_length(str) - hed - t);
				}
				break;
				
			case 1 :
				var w = string_splice(str, " ");
				_str = "";
				
				if(mode == 1) {
					hed *= array_length(w);
					tal *= array_length(w);
				}
				
				for( var i = hed; i < array_length(w) - tal; i++ )
					_str += (i == hed? "" : " ") + w[i];
				break;
				
			case 2 :
				_str = string_trim(_str);
				if(text != "") _str = string_trim(_str, [text]);
				break;
		}
		
		return _str;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var str = outputs[0].getValue();
		var bbox = draw_bbox;
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}