function Node_Iterator_Each_Input(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Loop Input";
	color = COLORS.node_blend_loop;
	is_group_io = true;
	
	manual_deletable = false;
	
	outputs[| 0] = nodeValue("Value in", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0 );
	outputs[| 0].getValueDefault = method(outputs[| 0], outputs[| 0].getValueRecursive); //Get value from outside loop
	outputs[| 0].getValueRecursive = function() {
		if(!variable_struct_exists(group, "iterated"))
			return outputs[| 0].getValueDefault();
			
		var ind = group.iterated;
		var val = group.getInputData(0);
		
		return [ array_safe_get(val, ind), group.inputs[| 0] ];
	}
	
	static step = function() {
		if(!variable_struct_exists(group, "iterated")) return;
		
		outputs[| 0].setType(group.inputs[| 0].type);
	}
	
	static onLoadGroup = function() { #region
		if(group == noone) nodeDelete(self);
	} #endregion
}