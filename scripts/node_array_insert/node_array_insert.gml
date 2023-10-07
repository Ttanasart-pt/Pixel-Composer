function Node_Array_Insert(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Array Insert";
	previewable = false;
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	inputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Index", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	inputs[| 2] = nodeValue("Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0)
		.setVisible(true, true);
	
	inputs[| 3] = nodeValue("Spread array", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false )
		.rejectArray();
		
	outputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0);
	
	static update = function(frame = PROJECT.animator.current_frame) {
		var _arr = getInputData(0);
		
		inputs[| 0].setType(VALUE_TYPE.any);
		inputs[| 2].setType(VALUE_TYPE.any);
		outputs[| 0].setType(VALUE_TYPE.any);
		
		if(!is_array(_arr)) return;
		
		var index = getInputData(1);
		var value = getInputData(2);
		var spred = getInputData(3);
		var _len = array_length(_arr);
		
		if(inputs[| 0].value_from != noone) {
			var type = inputs[| 0].value_from.type;
			inputs[| 0].setType(type);
			inputs[| 2].setType(type);
			outputs[| 0].setType(type);
		}
		
		var arr = array_clone(_arr);
		if(is_array(index)) {
			if(!is_array(value)) value = [ value ];
			for( var i = 0, n = array_length(index); i < n; i++ ) {
				if(index[i] < 0) index[i] = array_length(arr) - 1 + index[i];
				array_insert(arr, index[i], array_safe_get(value, i,, ARRAY_OVERFLOW.loop));
			}
		} else {
			if(index < 0) index = array_length(arr) + index;
			
			if(is_array(value) && spred) {
				for( var i = 0, n = array_length(value); i < n; i++ ) 
					array_insert(arr, index + i, value[i]);
			} else {
				array_insert(arr, index, value);
			}
		}
		
		outputs[| 0].setValue(arr);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_h3, fa_center, fa_center, COLORS._main_text);
		var idx = getInputData(1);
		
		var str	= string(idx);
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}