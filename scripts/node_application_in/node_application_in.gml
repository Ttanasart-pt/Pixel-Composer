function Node_Application_In(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "GUI In";
	update_on_frame = true;
	
	newInput(0, nodeValue_Surface("GUI", self));
	
	APP_SURF_OVERRIDE = true;
	
	static step = function() {
		LIVE_UPDATE = true;
	}
	
	static update = function() {
		var s = inputs[0].getValue();
		
		if(!is_surface(s)) return;
		
		surface_set_target(POST_APP_SURF);
		BLEND_OVERRIDE
		draw_surface_stretched(s, 0, 0, WIN_W, WIN_H);
		BLEND_NORMAL
		surface_reset_target();
	}
}