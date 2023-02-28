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
	
	outputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0);
	
	static update = function(frame = ANIMATOR.current_frame) {
		var _arr = inputs[| 0].getValue();
		
		inputs[| 0].type  = VALUE_TYPE.any;
		inputs[| 2].type  = VALUE_TYPE.any;
		outputs[| 0].type = VALUE_TYPE.any;
		
		if(!is_array(_arr)) return;
		
		var index = inputs[| 1].getValue();
		var value = inputs[| 2].getValue();
		var _len = array_length(_arr);
		
		if(inputs[| 0].value_from != noone) {
			var type = inputs[| 0].value_from.type;
			inputs[| 0].type  = type;
			inputs[| 2].type  = type;
			outputs[| 0].type = type;
		}
		
		var arr = array_clone(_arr);
		if(is_array(index)) {
			if(!is_array(value)) value = [ value ];
			for( var i = 0; i < array_length(index); i++ )
				array_insert(arr, index[i], array_safe_get(value, i,, ARRAY_OVERFLOW.loop));
		} else {
			if(is_array(value)) {
				for( var i = 0; i < array_length(value); i++ ) 
					array_insert(arr, index + i, value[i]);
			} else
				array_insert(arr, index, value);
		}
		
		outputs[| 0].setValue(arr);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		draw_set_text(f_h3, fa_center, fa_center, COLORS._main_text);
		var idx = inputs[| 1].getValue();
		
		var str	= string(idx);
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}