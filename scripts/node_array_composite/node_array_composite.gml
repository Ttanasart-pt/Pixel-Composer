function Node_Array_Composite(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Composite";
	setDimension(96, 32 + 24);
	
	newInput(0, nodeValue_Float("Array", self, []))
		.setArrayDepth(1)
		.setVisible(true, true);
	
	newInput(1, nodeValue_Float("Compose", self, []))
		.setArrayDepth(1)
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Array", self, VALUE_TYPE.float, 0))
		.setArrayDepth(1);
		
	static composite = function(arr, com) {
		__tmp_com = com;
		__tmp_len = array_length(com);
		
		return array_map(arr, function(val, ind) {
			var ret = array_create(__tmp_len);
			
			for( var i = 0; i < __tmp_len; i++ )
				ret[i] = __tmp_com[i] * val;
			
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
				res[i] = composite(_arr[i], _ker);
		} else 
			res = composite(_arr, _ker);
			
		outputs[0].setValue(res);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_array_composite, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}