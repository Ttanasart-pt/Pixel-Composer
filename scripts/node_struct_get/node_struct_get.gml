function Node_Struct_Get(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Struct Get";
	always_pad = true;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Struct(  "Struct" )).setVisible(true, true);
	newInput(1, nodeValue_Text(    "Key"    ));
	newInput(2, nodeValue_EScroll( "Type", 0, [ "Auto", "Number", "Text", "Surface", "Buffer", "Struct" ] ));
	
	newOutput(0, nodeValue_Output("Value", VALUE_TYPE.any, noone ));
	
	input_display_list = [ 0, 
		1, 2 
	];
	
	////- Node
	
	static getStructValue = function(str, keys) {
		var _pnt = str, val = 0;
		if(!is_struct(_pnt)) return [ VALUE_TYPE.any, val ];
		
		for( var i = 0, n = array_length(keys); i < n; i++ ) {
			var k = keys[i];
			
			if(!has(_pnt, k)) return [ VALUE_TYPE.float, 0 ];
				
			val = _pnt[$ k];
			if(i == n - 1) {
				if(is_struct(val)) {
					if(is(val, Surface))
						return [ VALUE_TYPE.surface, val.get() ];
						
					else if(is(val, Buffer))
						return [ VALUE_TYPE.buffer, val.buffer ];
						
					else 
						return [ VALUE_TYPE.struct, val ];
						
				} else if(is_array(val) && array_length(val))
					return [ is_string(val[0])? VALUE_TYPE.text : VALUE_TYPE.float, val ];
					
				return [ is_string(val)? VALUE_TYPE.text : VALUE_TYPE.float, val ];
			}
				
			if(is_struct(val))	_pnt = val;
			else				break;
		}
		
		return [ VALUE_TYPE.any, val ];
	}
	
	static update = function() {
		var str = getInputData(0);
		var key = getInputData(1);
		var typ = getInputData(2);
		
		var keys = string_splice(key, ".");
		var otyp = VALUE_TYPE.any;
		var oval = 0;
		
		if(is_array(str)) {
			oval = array_create(array_length(str));
			
			for( var i = 0, n = array_length(str); i < n; i++ ) {
				var _str = str[i];
				var _v   = getStructValue(_str, keys);
				
				otyp    = _v[0];
				oval[i] = _v[1];
			}
			
		} else {
			var v = getStructValue(str, keys);
			otyp  = v[0];
			oval  = v[1];
			
		}
		
		switch(typ) {
			case 0 : break;
			case 1 : otyp = VALUE_TYPE.float;   break;
			case 2 : otyp = VALUE_TYPE.text;    break;
			case 3 : otyp = VALUE_TYPE.surface; break;
			case 4 : otyp = VALUE_TYPE.buffer;  break;
			case 5 : otyp = VALUE_TYPE.struct;  break;
		}
		
		outputs[0].setType(otyp);
		outputs[0].setValue(oval);
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		var str  = getInputData(1);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}