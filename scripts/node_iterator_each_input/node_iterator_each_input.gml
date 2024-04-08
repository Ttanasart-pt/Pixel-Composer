function Node_Iterator_Each_Input(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Loop Input";
	color = COLORS.node_blend_loop;
	is_group_io = true;
	
	manual_deletable = false;
	
	outputs[| 0] = nodeValue("Value in", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0 );
	
	outputs[| 0].getValueDefault = method(outputs[| 0], outputs[| 0].getValueRecursive); //Get value from outside loop
	
	outputs[| 0].getValueRecursive = function(arr) {
		if(!variable_struct_exists(group, "iterated"))
			return outputs[| 0].getValueDefault(arr);
			
		var ind = group.iterated;
		var val = group.getInputData(0);
		var ivl = array_safe_get_fast(val, ind);
		
		arr[@ 0] = ivl;
		arr[@ 1] = group.inputs[| 0];
	}
	
	static step = function() {
		if(group == noone) return;
		if(!variable_struct_exists(group, "iterated")) return;
		
		if(outputs[| 0].setType(group.inputs[| 0].type))
			will_setHeight = true;
	}
	
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
	
	static onLoadGroup = function() { #region
		if(group == noone) destroy();
	} #endregion
}