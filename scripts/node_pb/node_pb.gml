function Node_PB(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "PB Element";
	icon = THEME.pixel_builder;
	fullUpdate = true;
	
	w = 128;
	h = 128;
	min_h = h;
	
	static getNextNodesRaw = getNextNodes;
	
	static getNextNodes = function() {
		if(!struct_has(group, "checkComplete")) return [];
		
		for( var i = 0; i < ds_list_size(outputs); i++ ) {
			var _ot  = outputs[| i];
			var _tos = _ot.getJunctionTo();
			
			if(array_length(_tos) > 0)
				return getNextNodesRaw();
		}
		
		return group.checkComplete();
	}
	
	static getPreviewValue = function() {
		return group.outputs[| 0];
	}
}