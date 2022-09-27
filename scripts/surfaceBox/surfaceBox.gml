function surfaceBox(_onModify, def_path = "") constructor {
	onModify  = _onModify;	
	self.def_path = def_path;
	
	active = false;
	hover  = false;
	open   = false;
	
	align = fa_center;
	
	static draw = function(_x, _y, _w, _h, _surface, _m, _rx, _ry) {
		if(!open) {
			if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
				draw_sprite_stretched(s_textbox, 1, _x, _y, _w, _h);
				if(active && mouse_check_button_pressed(mb_left)) {
					open = true;
					with(dialogCall(o_dialog_assetbox, _x + _w + _rx, _y + _ry)) {
						target = other;
						gotoDir(other.def_path);
					}
				}
				if(mouse_check_button(mb_left))
					draw_sprite_stretched(s_textbox, 2, _x, _y, _w, _h);	
			} else {
				draw_sprite_stretched(s_textbox, 0, _x, _y, _w, _h);		
			}
			
			var pad = 12;
			var sw = min(_w - pad, _h - pad);
			var sh = sw;
			
			var sx0 = _x + _w / 2 - sw / 2;
			var sx1 = sx0 + sw;
			var sy0 = _y + _h / 2 - sh / 2;
			var sy1 = sy0 + sh;
			
			draw_set_color(c_ui_blue_dkgrey);
			draw_rectangle(sx0, sy0, sx1, sy1, true);
			
			if(is_array(_surface))
				_surface = _surface[round(current_time / 250) % array_length(_surface)];
			
			if(is_surface(_surface)) {
				var sfw = surface_get_width(_surface);	
				var sfh = surface_get_height(_surface);	
				var ss  = min(sw / sfw, sh / sfh);
				
				draw_surface_ext(_surface, sx0, sy0, ss, ss, 0, c_white, 1);
			}
			
			draw_sprite_ext(s_scroll_box_arrow, 0, _x + _w - 20, _y + _h / 2, 1, 1, 0, c_ui_blue_grey, 1);
		}
		
		hover  = false;
		active = false;
	}
}