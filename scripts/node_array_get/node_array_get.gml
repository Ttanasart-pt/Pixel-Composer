function Node_Array_Get(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Array Get";
	previewable = false;
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	inputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Index", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setVisible(true, true);
	
	inputs[| 2] = nodeValue("Overflow", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Clamp", "Loop", "Ping Pong"])
		.rejectArray();
	
	inputs[| 3] = nodeValue("Index", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	outputs[| 0] = nodeValue("Value", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0);
	
	static step = function() {
		inputs[| 0].type  = VALUE_TYPE.any;
		outputs[| 0].type = VALUE_TYPE.any;
		
		if(inputs[| 0].value_from != noone) {
			inputs[| 0].type  = inputs[| 0].value_from.type;
			outputs[| 0].type = inputs[| 0].type;
		}
	}
	
	static getArray = function(_arr, index, _ovf, _dim = 0) {
		if(!is_array(_arr)) return;
		if(is_array(index)) return;
		
		var _len  = array_length(_arr);
		
		switch(_ovf) {
			case 0 :
				if(index < 0) index = _len - 1 + index;
				index = clamp(index, 0, _len - 1);
				break;
			case 1 :
				index = safe_mod(index, _len);
				if(index < 0) index = _len - 1 + index;
				break;
			case 2 :
				var _pplen = (_len - 1) * 2;
				index = safe_mod(abs(index), _pplen);
				if(index >= _len) 
					index = _pplen - index;
				break;
		}
		
		return array_safe_get(_arr, index);
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		var _arr = inputs[| 0].getValue();
		
		if(!is_array(_arr)) return;
		
		var index = inputs[| 1].getValue();
		var _ovf  = inputs[| 2].getValue();
		var _dim  = inputs[| 3].getValue();
		var res   = is_array(index)? array_create(array_length(index)) : 0;
		
		if(is_array(index)) {
			for( var i = 0; i < array_length(index); i++ )
				res[i] = getArray(_arr, index[i], _ovf, _dim);
		} else 
			res = getArray(_arr, index, _ovf, _dim);
		
		outputs[| 0].setValue(res);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_h3, fa_center, fa_center, COLORS._main_text);
		var idx = inputs[| 1].getValue();
		
		var str	= string(idx);
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}