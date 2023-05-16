function Node_Array_Copy(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Array Copy";
	previewable = false;
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	inputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0)
		.setArrayDepth(1)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Starting Index", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	inputs[| 2] = nodeValue("Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	outputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0)
		.setArrayDepth(1);
		
	static step = function() {
		var _typ = VALUE_TYPE.any;
		if(inputs[| 0].value_from != noone) _typ = inputs[| 0].value_from.type;
		
		inputs[| 0].type  = _typ;
		outputs[| 0].type = _typ;
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		var _arr = inputs[| 0].getValue();
		var _ind = inputs[| 1].getValue();
		var _siz = inputs[| 2].getValue();
		
		var _a = _arr, _res = [];
		for( var i = 0; i < array_length(_a); i++ ) {
			var _aa = _a[i];
			
			_res = _aa[_ind]
		}
		
		if(!is_array(_arr)) return;
		var res = [];
		
		for( var i = 0; i < _siz; i++ ) 
			res[i] = array_safe_get(_arr, _ind + i);
		
		outputs[| 0].setValue(res);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		
	}
}