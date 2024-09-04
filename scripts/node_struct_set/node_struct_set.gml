function Node_Struct_Set(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Struct Set";
	
	setDimension(96, 48);
	
	newInput(0, nodeValue_Struct("Struct", self, {}))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Text("Key", self, ""));
	
	newInput(2, nodeValue("Value", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0));
	
	newOutput(0, nodeValue_Output("Struct", self, VALUE_TYPE.struct, {}));
	
	static update = function() { 
		var str = getInputData(0);
		var key = getInputData(1);
		var val = getInputData(2);
		
		var keys = string_splice(key, ".");
		var _str = str;
		
		var out = outputs[0];
		
		for( var j = 0; j < array_length(keys); j++ ) {
			var k = keys[j];
				
			if(!variable_struct_exists(_str, k)) {
				out.setType(VALUE_TYPE.float);
				break;
			}
				
			var val = variable_struct_get(_str, k);
			if(j == array_length(keys) - 1) {
				if(is_struct(val)) {
					if(is_instanceof(val, Surface)) {
						out.setType(VALUE_TYPE.surface);
						val = val.get();
					} else if(is_instanceof(val, Buffer)) {
						out.setType(VALUE_TYPE.buffer);
						val = val.buffer;
					} else 
						out.setType(VALUE_TYPE.struct);
				} else if(is_array(val) && array_length(val))
					out.setType(is_string(val[0])? VALUE_TYPE.text : VALUE_TYPE.float);
				else
					out.setType(is_string(val)? VALUE_TYPE.text : VALUE_TYPE.float);
					
				out.setValue(val);
			}
				
			if(is_struct(val))	_str = val;
			else				break;
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var str  = getInputData(1);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}