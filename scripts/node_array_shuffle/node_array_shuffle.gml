function Node_Array_Shuffle(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Shuffle Array";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Array in", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, [])
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, irandom_range(10000, 99999))
		.rejectArray();
	
	outputs[| 0] = nodeValue("Shuffled array", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, []);
	
	static update = function(frame = PROJECT.animator.current_frame) {
		var arr = getInputData(0);
		var sed = getInputData(1);
		
		inputs[| 0].type = VALUE_TYPE.any;
		outputs[| 0].type = VALUE_TYPE.any;
		
		if(!is_array(arr)) return;
		arr = array_clone(arr);
		
		if(inputs[| 0].value_from != noone) {
			inputs[| 0].type = inputs[| 0].value_from.type;
			outputs[| 0].type = inputs[| 0].value_from.type;
		}
		
		random_set_seed(sed);
		arr = array_shuffle(arr);
		outputs[| 0].setValue(arr);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_array_shuffle, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}