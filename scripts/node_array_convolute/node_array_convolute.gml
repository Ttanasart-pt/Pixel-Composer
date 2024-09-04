function Node_Array_Convolute(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Convolute";
	setDimension(96, 32 + 24);
	
	newInput(0, nodeValue_Float("Array", self, 0))
		.setArrayDepth(1)
		.setVisible(true, true);
	
	newInput(1, nodeValue_Float("Kernel", self, []))
		.setArrayDepth(1)
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Array", self, VALUE_TYPE.float, 0))
		.setArrayDepth(1);
		
	static convolute = function(arr, ker) {
		__tmp_ker = ker;
		__tmp_arr = arr;
		__tmp_len = array_length(ker);
		__tmp_arn = array_length(arr);
		__tmp_st  = floor((__tmp_len - 1) / 2);
		
		return array_map(arr, function(val, ind) {
			var ret = 0;
			
			for(var i = 0; i < __tmp_len; i++) {
				var _ind = ind + i - __tmp_st;
				if(_ind < 0) continue;
				if(_ind >= __tmp_arn) continue;
				
				ret += __tmp_arr[_ind] * __tmp_ker[i];
			}
			
			return ret;
		});
	}
		
	static update = function(frame = CURRENT_FRAME) {
		var _arr = getInputData(0);
		var _ker = getInputData(1);
		
		if(!is_array(_arr) || !is_array(_ker)) return;
		if(array_empty(_arr) || array_empty(_ker)) return;
		
		var res;
		
		if(is_array(_arr[0])) {
			for( var i = 0, n = array_length(_arr); i < n; i++ ) 
				res[i] = convolute(_arr[i], _ker);
		} else 
			res = convolute(_arr, _ker);
			
		outputs[0].setValue(res);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_array_convolute, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}