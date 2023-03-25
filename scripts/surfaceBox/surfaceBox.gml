function surfaceBox(_onModify, def_path = "") : widget() constructor {
	onModify  = _onModify;	
	self.def_path = def_path;
	
	open   = false;
	open_rx = 0;
	open_ry = 0;
	
	align = fa_center;
	
	static trigger = function() {
		open = true;
		with(dialogCall(o_dialog_assetbox, x + w + open_rx, y + open_ry)) {
			target = other;
			gotoDir(other.def_path);
		}
	}
	
	static draw = function(_x, _y, _w, _h, _surface, _m, _rx, _ry) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		open_rx = _rx;
		open_ry = _ry;
		
		var hoverRect = point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h);
		
		if(!open) {
			draw_sprite_stretched(THEME.textbox, 3, _x, _y, _w, _h);
			
			if(hover && hoverRect) {
				draw_sprite_stretched(THEME.textbox, 1, _x, _y, _w, _h);
				if(mouse_press(mb_left, active))
					trigger();
				
				if(mouse_click(mb_left, active))
					draw_sprite_stretched(THEME.textbox, 2, _x, _y, _w, _h);	
			} else {
				draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _w, _h, c_white, 0.5 + 0.5 * interactable);
				if(mouse_press(mb_left)) deactivate();
			}
			
			var pad = ui(12);
			var sw = min(_w - pad, _h - pad);
			var sh = sw;
			
			var sx0 = _x + _w / 2 - sw / 2;
			var sx1 = sx0 + sw;
			var sy0 = _y + _h / 2 - sh / 2;
			var sy1 = sy0 + sh;
			
			draw_set_color(COLORS.widget_surface_frame);
			draw_rectangle(sx0, sy0, sx1, sy1, true);
			
			if(is_array(_surface) && array_length(_surface))
				_surface = _surface[safe_mod(round(current_time / 250), array_length(_surface))];
			
			if(is_surface(_surface)) {
				var sfw = surface_get_width(_surface);	
				var sfh = surface_get_height(_surface);	
				var ss  = min(sw / sfw, sh / sfh);
				var _sx = sx0 + sw / 2 - ss * sfw / 2;
				var _sy = sy0 + sh / 2 - ss * sfh / 2;
				
				draw_surface_ext_safe(_surface, _sx, _sy, ss, ss, 0, c_white, 1);
			}
			
			draw_sprite_ui_uniform(THEME.scroll_box_arrow, 0, _x + _w - ui(20), _y + _h / 2, 1, COLORS._main_icon);
		}
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _w + ui(6), _h + ui(6));	
		
		if(DRAGGING && DRAGGING.type == "Asset" && hover && hoverRect) {
			draw_sprite_stretched_ext(THEME.ui_panel_active, 0, _x, _y, _w, _h, COLORS._main_value_positive, 1);	
			if(mouse_release(mb_left))
				onModify(DRAGGING.data.path);
		}
		
		resetFocus();
	}
}