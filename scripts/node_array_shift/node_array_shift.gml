function Node_Array_Shift(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Array Shift";
	previewable = false;
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	inputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0)
		.setVisible(true, true);
		
	inputs[| 1] = nodeValue("Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
	
	outputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0);
	
	static update = function(frame = PROJECT.animator.current_frame) {
		var _arr = inputs[| 0].getValue();
		var _shf = inputs[| 1].getValue();
		
		inputs[| 0].type  = VALUE_TYPE.any;
		outputs[| 0].type = VALUE_TYPE.any;
		
		if(!is_array(_arr)) return;
		
		if(inputs[| 0].value_from != noone) {
			var type = inputs[| 0].value_from.type;
			inputs[| 0].type  = type;
			outputs[| 0].type = type;
		}
		
		var arr = [];
		for( var i = 0, n = array_length(_arr); i < n; i++ )
			arr[i] = array_safe_get(_arr, i - _shf,, ARRAY_OVERFLOW.loop);
		
		outputs[| 0].setValue(arr);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_array_shift, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}