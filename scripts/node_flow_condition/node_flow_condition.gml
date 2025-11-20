function Node_Flow_Condition(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name     = "Condition";
	doUpdate = doUpdateLite;
	setDimension(96, 48);
	
	////- =Condition
	newInput(0, nodeValue_Bool("Check value", false )).setVisible(true, true);
		
	newOutput(0, nodeValue_Output("Result", VALUE_TYPE.any, []));
	newOutput(1, nodeValue_Output("Bool", VALUE_TYPE.boolean, false));
	
	input_display_list = [ 
		[ "Condition", false ], 0, 
	]
	
	static update = function(frame = CURRENT_FRAME) {
		var _value = inputs[0].getValue();
		
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		
	}
}