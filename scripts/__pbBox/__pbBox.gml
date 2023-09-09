function __pbBox() constructor {
	layer = 0;
	
	x = 0;
	y = 0;
	w = 32;
	h = 32;
	
	layer_w = 32;
	layer_h = 32;
	
	mask	= noone;
	content = noone;
	
	mirror_h = false;
	mirror_v = false;
	
	rotation = 0;
	
	static drawOverlay = function(_x, _y, _s, color = COLORS._main_accent) {
		var _x0 = _x + x * _s;
		var _y0 = _y + y * _s;
		
		var _x1 = _x0 + w * _s;
		var _y1 = _y0 + h * _s;
		
		var _msk = is_surface(mask);
		
		draw_set_alpha(0.5 + 0.5 * !_msk);
		draw_set_color(color);
		draw_rectangle(_x0, _y0, _x1, _y1, true);
		draw_set_alpha(1);
		
		if(_msk) {
			var _sr = surface_get_target();
			var _ms = surface_create_size(_sr);
			
			surface_set_target(_ms);
				DRAW_CLEAR
				draw_surface_ext_safe(mask, _x0, _y0, _s, _s, 0, color, 1);
			surface_reset_target();
			
			shader_set(sh_pb_draw_mask);
				shader_set_dim(, _ms);
				draw_surface_ext_safe(_ms, 0, 0, 1, 1, 0, color, 1);
			shader_reset();
			
			surface_free(_ms);
		}
	}
	
	static clone = function() {
		var _pbbox = new __pbBox();
		
		_pbbox.layer = layer;
		_pbbox.x = x;
		_pbbox.y = y;
		_pbbox.w = w;
		_pbbox.h = h;
		
		_pbbox.layer_w = layer_w;
		_pbbox.layer_h = layer_h;
		
		_pbbox.mirror_h = mirror_h;
		_pbbox.mirror_v = mirror_v;
		
		_pbbox.rotation = rotation;
		
		_pbbox.mask		= surface_clone(mask);
		_pbbox.content	= surface_clone(content);
		
		return _pbbox;
	}
	
	static free = function() {
		surface_free_safe(mask);
		surface_free_safe(content);
	}
}