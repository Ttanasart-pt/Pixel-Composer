function Node_Struct_Get(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Struct Get";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Struct", self, JUNCTION_CONNECT.input, VALUE_TYPE.struct, {})
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Key", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
	
	outputs[| 0] = nodeValue("Struct", self, JUNCTION_CONNECT.output, VALUE_TYPE.struct, {});
	
	function update() { 
		var str = inputs[| 0].getValue();
		var key = inputs[| 1].getValue();
		
		var keys = string_splice(key, ".");
		var _str = str;
		
		var out = outputs[| 0];
		
		for( var j = 0; j < array_length(keys); j++ ) {
			var k = keys[j];
				
			if(!variable_struct_exists(_str, k)) {
				out.setValue(0);
				out.type = VALUE_TYPE.float;
				break;
			}
				
			var val = variable_struct_get(_str, k);
			if(j == array_length(keys) - 1) {
				if(is_struct(val)) {
					if(instanceof(val) == "Surface") {
						out.type = VALUE_TYPE.surface;
						val = val.get();
					} else if(instanceof(val) == "Buffer") {
						out.type = VALUE_TYPE.buffer;
						val = val.buffer;
					} else 
						out.type = VALUE_TYPE.struct;
				} else if(is_array(val) && array_length(val))
					out.type = is_string(val[0])? VALUE_TYPE.text : VALUE_TYPE.float;
				else
					out.type = is_string(val)? VALUE_TYPE.text : VALUE_TYPE.float;
					
				out.setValue(val);
			}
				
			if(is_struct(val))	_str = val;
			else				break;
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var str  = inputs[| 1].getValue();
		
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}