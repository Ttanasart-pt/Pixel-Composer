function Node_Iterator_Reduce_Input(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Reduce Input";
	color = COLORS.node_blend_loop;
	loop  = noone;
	parameters.inline_draw_input = true;
	setDimension(96, 48);
	
	loopable = false;
	clonable = false;
	
	inline_input         = false;
	manual_ungroupable	 = false;
	
	newInput( 0, nodeValue_Any("Array in",   [] )).setVisible(true, true);
	newInput( 1, nodeValue_Any("Init Value", 0  )).setVisible(true, true);
	// 2
	
	newOutput( 0, nodeValue_Output("Acc. result", VALUE_TYPE.any, 0 ));
	newOutput( 1, nodeValue_Output("Value",       VALUE_TYPE.any, 0 ));
	
	static onGetPreviousNodes = function(arr) /*=>*/ { array_push(arr, loop); }
	
	static update = function() {
		if(!is(loop, Node_Iterator_Reduce_Inline)) return;
		
		var _typ = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[0].setType(_typ);
		inputs[1].setType(_typ);
		outputs[0].setType(_typ);
		outputs[1].setType(_typ);
		
		var val = inputs[0].getValue();
		var itr = loop.iterated - 1;
		
		if(!is_array(val)) return;
		
		if(itr == 0) {
			if(inputs[1].value_from != noone)
				 outputs[0].setValue(getInputData(1));
			else outputs[0].setValue(array_safe_get_fast(val, 0));
		}
		
		outputs[1].setValue(array_safe_get_fast(val, itr));
	}
}