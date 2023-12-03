function Node_Struct_Get(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Struct Get";
	
	w = 96;
	
	inputs[| 0] = nodeValue("Struct", self, JUNCTION_CONNECT.input, VALUE_TYPE.struct, {})
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Key", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
	
	outputs[| 0] = nodeValue("Struct", self, JUNCTION_CONNECT.output, VALUE_TYPE.struct, {});
	
	static getStructValue = function(str, keys) { #region
		var _pnt = str, val = 0;
		if(!is_struct(_pnt)) return [ VALUE_TYPE.any, val ];
		
		for( var j = 0; j < array_length(keys); j++ ) {
			var k = keys[j];
			
			if(!variable_struct_exists(_pnt, k)) 
				return [ VALUE_TYPE.float, 0 ];
				
			val = variable_struct_get(_pnt, k);
			if(j == array_length(keys) - 1) {
				if(is_struct(val)) {
					if(is_instanceof(val, Surface))
						return [ VALUE_TYPE.surface, val.get() ];
					else if(is_instanceof(val, Buffer))
						return [ VALUE_TYPE.buffer, val.buffer ];
					else 
						return [ VALUE_TYPE.struct, val ];
				} else if(is_array(val) && array_length(val))
					return [ is_string(val[0])? VALUE_TYPE.text : VALUE_TYPE.float, val ];
				else
					return [ is_string(val)? VALUE_TYPE.text : VALUE_TYPE.float, val ];
			}
				
			if(is_struct(val))	_pnt = val;
			else				break;
		}
		
		return [ VALUE_TYPE.any, val ];
	} #endregion
	
	static update = function() { #region
		var str = getInputData(0);
		var key = getInputData(1);
		
		var keys = string_splice(key, ".");
		
		if(is_array(str)) {
			var typ = VALUE_TYPE.any;
			var val = array_create(array_length(str));
			
			for( var i = 0, n = array_length(str); i < n; i++ ) {
				var _str = str[i];
				var _v   = getStructValue(_str, keys);
				
				typ    = _v[0];
				val[i] = _v[1];
			}
			
			outputs[| 0].setType(typ);
			outputs[| 0].setValue(val);
		} else {
			var val  = getStructValue(str, keys);
		
			outputs[| 0].setType(val[0]);
			outputs[| 0].setValue(val[1]);
		}
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		var str  = getInputData(1);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	} #endregion
}