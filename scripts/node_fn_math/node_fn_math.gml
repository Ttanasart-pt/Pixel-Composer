#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Fn_Math", "Operation > Add",      "A", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[_n.inl + 0].setValue(0); });
		addHotkey("Node_Fn_Math", "Operation > Minus",    "S", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[_n.inl + 0].setValue(1); });
		addHotkey("Node_Fn_Math", "Operation > Multiply", "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[_n.inl + 0].setValue(2); });
	});
#endregion

function Node_Fn_Math(_x, _y, _group = noone) : Node_Fn(_x, _y, _group) constructor {
	name       = "Math";
	time_based = false;
	
	newInput(inl + 0, nodeValue_Enum_Scroll("Operation", 2, [ "Add", "Minus", "Multiply" ] ));
	
	newInput(inl + 1, nodeValue_Float("Value 1", 0 ))
		.setVisible(true, true);
	
	newInput(inl + 2, nodeValue_Float("Value 2", 0 ))
		.setVisible(true, true);
		
	array_append(input_display_list, [
		["Value",	false], inl + 0, inl + 1, inl + 2,  
	]);
	
	type  = 0;
	
	static __fnEval = function(_x) {
		switch(type) {
			case 0 : return _x[0] + _x[1];
			case 1 : return _x[0] - _x[1];
			case 2 : return _x[0] * _x[1];
		}
		
		return 0;
	}
	
	static refreshDisplayX = function(i) { 
		var _v0 = getInputSingle(inl + 1);
		var _v1 = getInputSingle(inl + 2);
		
		var _f0 = inputs[inl + 1].value_from;
		if(_f0 != noone && is_instanceof(_f0.node, Node_Fn)) 
			_v0 = _f0.node.getDisplayX(i);
		
		var _f1 = inputs[inl + 2].value_from;
		if(_f1 != noone && is_instanceof(_f1.node, Node_Fn)) 
			_v1 = _f1.node.getDisplayX(i);
			
		return [ _v0, _v1 ]; 
	}
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) { #region
		type   = _data[inl + 0];
		var v0 = _data[inl + 1];
		var v1 = _data[inl + 2];
		
		var val = __fnEval([ v0, v1 ]);
		
		text_display = val;
		return val;
	} #endregion
	
}