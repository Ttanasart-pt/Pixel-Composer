function Node_Application_In(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "GUI In";
	update_on_frame = true;
	
	inputs[| 0] = nodeValue("GUI", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	static step = function() { #region
		var s = inputs[| 0].getValue();
		
		APP_SURF_OVERRIDE = false;
		if(!is_surface(s)) return;
		
		APP_SURF_OVERRIDE = true;
		surface_set_target(POST_APP_SURF);
			BLEND_OVERRIDE
			draw_surface_stretched(s, 0, 0, WIN_W, WIN_H);
			BLEND_NORMAL
		surface_reset_target();
	} #endregion
}