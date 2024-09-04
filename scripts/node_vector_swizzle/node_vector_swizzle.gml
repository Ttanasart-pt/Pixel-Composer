function Node_Vector_Swizzle(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Swizzle";
	color = COLORS.node_blend_number;
	setDimension(96, 48);
	
	newInput(0, nodeValue("Vector", self, CONNECT_TYPE.input, VALUE_TYPE.float, []))
		.setArrayDepth(1)
		.setVisible(true, true);
	
	newInput(1, nodeValue_Text("Swizzle", self, ""));
		
	newOutput(0, nodeValue_Output("Result", self, VALUE_TYPE.float, [] ));
	
	static char_get_index = function(_chr) {
		switch(string_lower(_chr)) {
			case "r" : 
			case "x" : 
				return 0;
				
			case "g" : 
			case "y" : 
				return 1;
				
			case "b" : 
			case "z" : 
				return 2;
				
			case "a" : 
			case "w" : 
				return 3;
		}
		
		return 0;
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		var _vec = _data[0];
		var _swz = _data[1];
		
		var amo = string_length(_swz);
		if(amo == 0) return _vec;
		
		var ind = 1;
		var ch, ix;
		var _v = [];
		
		repeat(amo) {
			ch = string_char_at(_swz, ind++);
			ix = char_get_index(ch);
			
			array_push(_v, array_safe_get(_vec, ix));
		}
		
		return amo == 1? _v[0] : _v;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var val  = getInputData(1);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, val);
	}
}