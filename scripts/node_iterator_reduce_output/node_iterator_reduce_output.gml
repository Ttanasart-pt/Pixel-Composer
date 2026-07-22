function Node_Iterator_Reduce_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Reduce Output";
	color = COLORS.node_blend_loop;
	parameters.inline_draw_output = true;
	setDimension(96, 48);
	
	loopable = false;
	clonable = false;
	
	inline_output        = false;
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue_Any( "Output" )).setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Result", VALUE_TYPE.any, noone ));
	
	static getNextNodes = function() {
		if(loop.bypassNextNode()) return loop.getNextNodes();
		
		logNodeDebug($"Loop complete");
		return getNextNodesRaw();
	}
	
	static update = function(frame = CURRENT_FRAME) {
		if(!is(loop, Node_Iterator_Reduce_Inline)) return;
		
		var _typ = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[0].setType(_typ);
		outputs[0].setType(_typ);
		
		var val = getInputData(0);
		
		if(_typ == VALUE_TYPE.surface) val = surface_array_clone(val);
		outputs[0].setValue(val);
		
		if(_typ == VALUE_TYPE.surface) val = surface_array_clone(val);
		loop.input_node.outputs[0].setValue(val);
	}
}