function Node_create_Timeline_Preview(_x, _y) {
	var node = new Node_Timeline_Preview(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Timeline_Preview(_x, _y) : Node(_x, _y) constructor {
	name = "Timeline";
	use_cache = true;
	color = COLORS.node_blend_number;
	
	w = 96;
	min_h = 0;
	
	PANEL_ANIMATION.timeline_preview = self;
	
	inputs[| 0] = nodeValue(0, "Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	static update = function() {
		var _inSurf = inputs[| 0].getValue();
		if(_inSurf == 0) return;
		
		if(is_array(_inSurf)) {
			if(surface_exists(_inSurf[preview_index]))
				cacheCurrentFrame(_inSurf[preview_index]);	
		} else if(surface_exists(_inSurf))
			cacheCurrentFrame(_inSurf);
	}
}