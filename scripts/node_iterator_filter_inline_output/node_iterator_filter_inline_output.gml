function Node_Iterator_Filter_Inline_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Filter Output";
	color = COLORS.node_blend_loop;
	loop  = noone;
	
	manual_ungroupable	 = false;
	
	inputs[| 0] = nodeValue("Value out", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0 )
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Filter result", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false )
		.setVisible(true, true);
		
	outputs[| 0] = nodeValue("Array out", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, [] );
	
	static getNextNodes = function() { #region
		if(loop.bypassNextNode())
			return loop.getNextNodes();
		return getNextNodesRaw();
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		if(!is_instanceof(loop, Node_Iterate_Filter_Inline)) return;
		
		var _typ = inputs[| 0].value_from == noone? VALUE_TYPE.any : inputs[| 0].value_from.type;
		inputs[| 0].setType(_typ);
		outputs[| 0].setType(_typ);
		
		var val = getInputData(0);
		var res = getInputData(1);
		var arr = outputs[| 0].getValue();
		var itr = loop.iterated - 1;
		
		if(res) array_push(arr, val);
		outputs[| 0].setValue(arr);
	} #endregion
}