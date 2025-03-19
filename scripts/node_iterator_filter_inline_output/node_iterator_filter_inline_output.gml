function Node_Iterator_Filter_Inline_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Filter Output";
	color = COLORS.node_blend_loop;
	loop  = noone;
	setDimension(96, 48);
	
	loopable = false;
	clonable = false;
	
	inline_output        = false;
	inline_parent_object = "Node_Iterate_Filter_Inline";
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue("Value out", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0 ))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Bool("Filter result", self, false ))
		.setVisible(true, true);
		
	newOutput(0, nodeValue_Output("Array out", self, VALUE_TYPE.any, [] ));
	
	static getNextNodes = function(checkLoop = false) { #region
		if(loop.bypassNextNode())
			return loop.getNextNodes();
		return getNextNodesRaw();
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		if(!is_instanceof(loop, Node_Iterate_Filter_Inline)) return;
		
		var _typ = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[0].setType(_typ);
		outputs[0].setType(_typ);
		
		var val = getInputData(0);
		var res = getInputData(1);
		var arr = outputs[0].getValue();
		var itr = loop.iterated - 1;
		
		if(res) array_push(arr, val);
		outputs[0].setValue(arr);
	} #endregion
}