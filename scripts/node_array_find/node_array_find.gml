function Node_Array_Find(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name		= "Array Find";
	previewable = false;
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	inputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0)
		.setVisible(true, true)
		.rejectArray();
	
	outputs[| 0] = nodeValue("Index", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, 0);
	
	static update = function(frame = ANIMATOR.current_frame) {
		var _arr = inputs[| 0].getValue();
		
		inputs[| 0].type  = VALUE_TYPE.any;
		inputs[| 1].type  = VALUE_TYPE.any;
		
		if(!is_array(_arr)) return;
		
		var value = inputs[| 1].getValue();
		
		if(inputs[| 0].value_from != noone) {
			var type = inputs[| 0].value_from.type;
			inputs[| 0].type  = type;
			inputs[| 1].type  = type;
		}
		
		outputs[| 0].setValue(array_find(_arr, value));
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		draw_set_text(f_h3, fa_center, fa_center, COLORS._main_text);
		var idx = outputs[| 0].getValue();
		
		var str	= string(idx);
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}