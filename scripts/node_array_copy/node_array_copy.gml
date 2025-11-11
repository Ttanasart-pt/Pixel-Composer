function Node_Array_Copy(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Copy";
	setDimension(96, 48);
	
	newInput(0, nodeValue("Array", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0))
		.setArrayDepth(1)
		.setVisible(true, true);
	
	newInput(1, nodeValue_Int("Starting Index", 0));
	
	newInput(2, nodeValue_Int("Size", 1));
	
	newOutput(0, nodeValue_Output("Array", VALUE_TYPE.any, 0))
		.setArrayDepth(1);
		
	static update = function(frame = CURRENT_FRAME) {
		var _typ = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[0].setType(_typ);
		outputs[0].setType(_typ);
		
		var _arr = getInputData(0);
		var _ind = getInputData(1);
		var _siz = getInputData(2);
		if(!is_array(_arr)) return;
		
		var res = [];
		
		if(_siz < 0) _siz = array_length(_arr) + _siz;
		if(_ind < 0) _ind = array_length(_arr) + _ind;
		
		for( var i = 0; i < _siz; i++ ) 
			res[i] = array_safe_get_fast(_arr, _ind + i, 0);
		
		outputs[0].setValue(res);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		if(bbox.h < 1) return;
		
		if(outputs[0].type == VALUE_TYPE.color) {
			var pal = outputs[0].getValue();
			if(array_empty(pal)) return;
			if(is_array(pal[0])) pal = pal[0];
			
			drawPaletteBBOX(pal, bbox);
		}
	}
}