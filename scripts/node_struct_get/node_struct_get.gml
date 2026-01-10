function Node_Struct_Get(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Struct Get";
	always_pad = true;
	setDimension(96, 48);
	
	__type_enum = [ "Auto", "Number", "Text", "Surface", "Buffer", "Struct", "Gradient" ];
	newInput(0, nodeValue_Struct(  "Struct" )).setVisible(true, true);
	newInput(1, nodeValue_Text(    "Key"    ));
	newInput(2, nodeValue_EScroll( "Type", 0, __type_enum ));
	
	newOutput(0, nodeValue_Output("Value", VALUE_TYPE.any, noone ));
	
	input_display_list = [ 0, 
		1, 2 
	];
	
	////- Node
	
	static getStructValue = function(str, keys) {
		if(!is_struct(str)) return [ VALUE_TYPE.any, 0 ];
		
		var pnt = str;
		var val, key;
		
		for( var i = 0, n = array_length(keys) - 1; i < n; i++ ) {
			key = keys[i];
			val = pnt[$ key];
			
			if(is_struct(val)) pnt = val;
			else return [ VALUE_TYPE.any, 0 ];
		}
		
		key = array_last(keys);
		val = pnt[$ key];
		if(val == undefined) return [ VALUE_TYPE.any, 0 ];
		
		if(ref_surface(val)) return [ VALUE_TYPE.surface,  val ];
		if(ref_buffer(val))  return [ VALUE_TYPE.buffer,   val ];
		if(is_struct(val)) {
			if(is(val, gradientObject)) return [ VALUE_TYPE.gradient, val ];
			return [ VALUE_TYPE.struct, val ];
		} 
		
		if(is_array(val) && array_length(val))
			return [ is_string(val[0])? VALUE_TYPE.text : VALUE_TYPE.float, val ];
			
		return [ is_string(val)? VALUE_TYPE.text : VALUE_TYPE.float, val ];
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
		
		switch(__type_enum[typ]) {
			case "Number"   : otyp = VALUE_TYPE.float;    break;
			case "Text"     : otyp = VALUE_TYPE.text;     break;
			case "Surface"  : otyp = VALUE_TYPE.surface;  break;
			case "Buffer"   : otyp = VALUE_TYPE.buffer;   break;
			case "Struct"   : otyp = VALUE_TYPE.struct;   break;
			case "Gradient" : otyp = VALUE_TYPE.gradient; break;
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