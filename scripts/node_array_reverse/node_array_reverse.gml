function Node_Array_Reverse(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Array Reverse";
	previewable = false;
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	inputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0)
		.setVisible(true, true);
		
	outputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0);
	
	static update = function(frame = CURRENT_FRAME) {
		var _arr = getInputData(0);
		
		inputs[| 0].setType(VALUE_TYPE.any);
		outputs[| 0].setType(VALUE_TYPE.any);
		
		if(!is_array(_arr)) return;
		
		if(inputs[| 0].value_from != noone) {
			var type = inputs[| 0].value_from.type;
			inputs[| 0].setType(type);
			outputs[| 0].setType(type);
		}
		
		_arr = array_reverse(_arr);
		
		outputs[| 0].setValue(_arr);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_array_reverse, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}