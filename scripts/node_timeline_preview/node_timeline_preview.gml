function Node_Timeline_Preview(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Timeline";
	use_cache = CACHE_USE.auto;
	color = COLORS.node_blend_number;
	
	setDimension(96, 48);
	
	
	PANEL_ANIMATION.timeline_preview = self;
	
	newInput(0, nodeValue_Surface("Surface", self));
	
	static update = function(frame = CURRENT_FRAME) {
		var _inSurf = getInputData(0);
		if(_inSurf == 0) return;
		
		if(is_array(_inSurf)) {
			if(surface_exists(_inSurf[preview_index]))
				cacheCurrentFrame(_inSurf[preview_index]);	
		} else if(surface_exists(_inSurf))
			cacheCurrentFrame(_inSurf);
	}
}