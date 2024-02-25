function Node_Iterator_Filter_Input(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Value";
	color = COLORS.node_blend_loop;
	is_group_io = true;
	
	manual_deletable = false;
	
	outputs[| 0] = nodeValue("Value in", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0 );
	outputs[| 0].getValueDefault = method(outputs[| 0], outputs[| 0].getValueRecursive); //Get value from outside loop
	outputs[| 0].getValueRecursive = function() { #region
		if(!variable_struct_exists(group, "iterated"))
			return outputs[| 0].getValueDefault();
			
		var ind = group.iterated;
		var val = group.getInputData(0);
		
		return [ array_safe_get(val, ind), group.inputs[| 0] ];
	} #endregion
	
	static step = function() { #region
		if(group == noone) return noone;
		if(!variable_struct_exists(group, "iterated")) return;
		
		if(outputs[| 0].setType(group.inputs[| 0].type))
			will_setHeight = true;
	} #endregion
	
	static getPreviewValues = function() { #region
		if(group == noone) return noone;
		
		switch(group.inputs[| 0].type) {
			case VALUE_TYPE.surface :
			case VALUE_TYPE.dynaSurface :
				break;
			default :
				return noone;
		}
		
		return group.getInputData(0);
	} #endregion
	
	static getGraphPreviewSurface = function() { #region
		if(group == noone) return noone;
		
		switch(group.inputs[| 0].type) {
			case VALUE_TYPE.surface :
			case VALUE_TYPE.dynaSurface :
				break;
			default :
				return noone;
		}
		
		return group.getInputData(0);
	} #endregion
	
}