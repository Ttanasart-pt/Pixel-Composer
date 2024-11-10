function surfaceDynaBox() : widget() constructor {
	
	static trigger = function() {}
	
	static setInteract = function(interactable) { }
	
	static drawParam = function(params) {
		return draw(params.x, params.y, params.w, params.h, params.data);
	}
	
	static draw = function(_x, _y, _w, _h, _surface) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		draw_sprite_stretched(THEME.textbox, 3, _x, _y, _w, _h);
		if(!is(_surface, dynaSurf)) return h;
		
		_surface = _surface.getSurfacePreview();
		
		var pad = ui(12);
		var sw = min(_w - pad, _h - pad);
		var sh = sw;
		
		var sx0 = _x + _w / 2 - sw / 2;
		var sx1 = sx0 + sw;
		var sy0 = _y + _h / 2 - sh / 2;
		var sy1 = sy0 + sh;
		
		ui_rect(sx0, sy0, sx1, sy1, COLORS.widget_surface_frame);
		
		if(surface_exists(_surface)) {
			var sfw = surface_get_width(_surface);	
			var sfh = surface_get_height(_surface);	
			var ss  = min(sw / sfw, sh / sfh);
			var _sx = sx0 + sw / 2 - ss * sfw / 2;
			var _sy = sy0 + sh / 2 - ss * sfh / 2;
			
			draw_surface_ext_safe(_surface, _sx, _sy, ss, ss, 0, c_white, 1);
		}
		
		resetFocus();
		
		return h;
	}
	
	static clone = function() {
		return new surfaceDynaBox();
	}
}