function Node_Array_Trim(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Trim";
	setDimension(96, 48);
	
	newInput(0, nodeValue(     "Array",      self, CONNECT_TYPE.input, VALUE_TYPE.any, 0)).setArrayDepth(1).setVisible(true, true);
	newInput(1, nodeValue_Int( "Trim Start", self, 0));
	newInput(2, nodeValue_Int( "Trim End",   self, 0));
	
	newOutput(0, nodeValue_Output("Array", self, VALUE_TYPE.any, 0))
		.setArrayDepth(1);
		
	static update = function(frame = CURRENT_FRAME) {
		var _typ = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[0].setType(_typ);
		outputs[0].setType(_typ);
		
		var _arr = getInputData(0);
		var _tst = getInputData(1);
		var _ted = getInputData(2);
		if(!is_array(_arr)) return;
		
		_tst = max(0, _tst);
		_ted = max(0, _ted);
		
		var res = [];
		for( var i = _tst, n = array_length(_arr) - _ted; i < n; i++ ) 
			array_push(res, _arr[i]);
		
		outputs[0].setValue(res);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		if(outputs[0].type == VALUE_TYPE.color) {
			var pal = outputs[0].getValue();
			if(array_empty(pal)) return;
			if(is_array(pal[0])) pal = pal[0];
			
			drawPaletteBBOX(pal, bbox);
		}
	}
}