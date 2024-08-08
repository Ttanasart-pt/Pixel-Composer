function Node_PB(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "PB Element";
	icon = THEME.pixel_builder;
	fullUpdate = true;
		
	static getNextNodesRaw = getNextNodes;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(drawOverlayPB != noone) 
			drawOverlayPB(active, _x, _y, _s, _mx, _my, _snx, _sny);
			
		for( var i = 0; i < array_length(outputs); i++ ) {
			if(outputs[i].type != VALUE_TYPE.pbBox) continue;
			
			var _box = outputs[i].getValue();
			if(!is_array(_box)) _box = [ _box ];
			
			for( var j = 0; j < array_length(_box); j++ ) {
				if(!is_instanceof(_box[j], __pbBox)) continue;
				_box[j].drawOverlay(_x, _y, _s, c_red);
			}
		}
	}
	
	static drawOverlayPB = noone;
	
	static getNextNodes = function() {
		if(!struct_has(group, "checkComplete")) return [];
		
		for( var i = 0; i < array_length(outputs); i++ ) {
			var _ot  = outputs[i];
			var _tos = _ot.getJunctionTo();
			
			if(array_length(_tos) > 0)
				return getNextNodesRaw();
		}
		
		return group.checkComplete();
	}
	
	static getPreviewValues = function() { return group.outputs[0].getValue(); }
}