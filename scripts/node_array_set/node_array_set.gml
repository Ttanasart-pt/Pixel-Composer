function Node_Array_Set(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Set";
	setDimension(96, 48);
	
	newInput(0, nodeValue("Array", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Int("Index", self, 0));
	
	newInput(2, nodeValue("Value", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Array", self, VALUE_TYPE.any, 0));
	
	static update = function(frame = CURRENT_FRAME) {
		var _arr = getInputData(0);
		
		inputs[0].setType(VALUE_TYPE.any);
		inputs[2].setType(VALUE_TYPE.any);
		outputs[0].setType(VALUE_TYPE.any);
		
		if(!is_array(_arr)) return;
		
		var index = getInputData(1);
		var value = getInputData(2);
		var _len = array_length(_arr);
		
		if(inputs[0].value_from != noone) {
			var type = inputs[0].value_from.type;
			inputs[0].setType(type);
			inputs[2].setType(type);
			outputs[0].setType(type);
		}
		
		var arr = array_clone(_arr);
		if(is_array(index)) {
			if(!is_array(value)) value = [ value ];
			for( var i = 0, n = array_length(index); i < n; i++ ) {
				if(index[i] < 0) index[i] = array_length(arr) + index[i];
				array_safe_set(arr, index[i], array_safe_get(value, i,, ARRAY_OVERFLOW.loop));
			}
		} else {
			if(index < 0) index = array_length(arr) + index;
			array_safe_set(arr, index, value);
		}
		
		outputs[0].setValue(arr);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var idx  = getInputData(1);
		var str	 = string(idx);
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	 = string_scale(str, bbox.w, bbox.h);
		
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}