function Node_Array_Copy(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Copy";
	setDimension(96, 32 + 24);
	
	inputs[0] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0)
		.setArrayDepth(1)
		.setVisible(true, true);
	
	newInput(1, nodeValue_Int("Starting Index", self, 0));
	
	newInput(2, nodeValue_Int("Size", self, 1));
	
	outputs[0] = nodeValue_Output("Array", self, VALUE_TYPE.any, 0)
		.setArrayDepth(1);
		
	static step = function() {
		var _typ = VALUE_TYPE.any;
		if(inputs[0].value_from != noone) _typ = inputs[0].value_from.type;
		
		inputs[0].setType(_typ);
		outputs[0].setType(_typ);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _arr = getInputData(0);
		var _ind = getInputData(1);
		var _siz = getInputData(2);
		
		if(!is_array(_arr)) return;
		var res = [];
		
		for( var i = 0; i < _siz; i++ ) 
			res[i] = array_safe_get_fast(_arr, _ind + i);
		
		outputs[0].setValue(res);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		
	}
}