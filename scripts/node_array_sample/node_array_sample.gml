function Node_Array_Sample(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Sample";
	setDimension(96, 32 + 24);
	
	inputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [])
		.setArrayDepth(1)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Step", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0)
		.setArrayDepth(1);
		
	static sample = function(arr, stp) {
		__temp_arr = arr;
		__temp_stp = stp;
		
		var _len = floor(array_length(arr));
		var _siz = floor(_len / stp);
		
		var _res = array_create_ext(_siz, function(_i) {
			return __temp_arr[_i * __temp_stp];
		});
		
		return _res;
	}
		
	static update = function(frame = CURRENT_FRAME) {
		var _arr = getInputData(0);
		var _stp = getInputData(1);
		
		if(array_empty(_arr)) return;
		
		var res;
		
		if(is_array(_arr[0])) {
			for( var i = 0, n = array_length(_arr); i < n; i++ ) 
				res[i] = sample(_arr[i], _stp);
		} else 
			res = sample(_arr, _stp);
		
		outputs[| 0].setValue(res);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_array_sample, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}