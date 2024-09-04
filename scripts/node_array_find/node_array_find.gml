function Node_Array_Find(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Find";
	setDimension(96, 32 + 24);
	
	newInput(0, nodeValue("Array", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0))
		.setVisible(true, true);
	
	newInput(1, nodeValue("Value", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0))
		.setVisible(true, true)
		.rejectArray();
	
	newOutput(0, nodeValue_Output("Index", self, VALUE_TYPE.integer, 0));
	
	static update = function(frame = CURRENT_FRAME) {
		var _arr = getInputData(0);
		
		inputs[0].setType(VALUE_TYPE.any);
		inputs[1].setType(VALUE_TYPE.any);
		
		if(!is_array(_arr)) return;
		
		var value = getInputData(1);
		
		if(inputs[0].value_from != noone) {
			var type = inputs[0].value_from.type;
			inputs[0].setType(type);
			inputs[1].setType(type);
		}
		
		outputs[0].setValue(array_find(_arr, value));
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var idx = outputs[0].getValue();
		
		var str	= string(idx);
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}