function Node_Array_Find(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Find";
	setDimension(96, 48);
	
	newInput(0, nodeValue("Array", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0))
		.setVisible(true, true);
	
	newInput(1, nodeValue("Value", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0))
		.setVisible(true, true)
		.rejectArray();
	
	newOutput(0, nodeValue_Output("Index", VALUE_TYPE.integer, 0));
	
	static update = function(frame = CURRENT_FRAME) {
		var type = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[0].setType(type);
		inputs[1].setType(type);
		
		var _arr = getInputData(0);
		if(!is_array(_arr)) return;
		
		var value = getInputData(1);
		outputs[0].setValue(array_find(_arr, value));
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, string(outputs[0].getValue()));
	}
}