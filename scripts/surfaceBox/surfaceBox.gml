function surfaceBox(_onModify, def_path = "") : widget() constructor {
	onModify  = _onModify;	
	self.def_path = def_path;
	
	open   = false;
	open_rx = 0;
	open_ry = 0;
	
	align = fa_center;
	display_data = {};
	
	cb_atlas_crop = new checkBox(function() { 
		display_data.atlas_crop = !display_data.atlas_crop; 
		display_data.update();
	});
	
	static trigger = function() {
		open = true;
		with(dialogCall(o_dialog_assetbox, x + w + open_rx, y + open_ry)) {
			target = other;
			gotoDir(other.def_path);
		}
	}
	
	static setInteract = function(interactable) { 
		self.interactable = interactable;
		cb_atlas_crop.interactable = true;
	}
	
	static drawParam = function(params) {
		return draw(params.x, params.y, params.w, params.h, params.data, params.display_data, params.m, params.rx, params.ry);
	}
	
	static draw = function(_x, _y, _w, _h, _surface, _display_data, _m, _rx, _ry) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		open_rx = _rx;
		open_ry = _ry;
		display_data = _display_data;
		
		var hoverRect = point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h);
		var _type = VALUE_TYPE.surface;
		
		var _surf_single = _surface;
		if(is_array(_surf_single) && !array_empty(_surf_single))
			_surf_single = _surf_single[0];
			
		     if(is_instanceof(_surf_single, dynaSurf))		_type = VALUE_TYPE.dynaSurface;
		else if(is_instanceof(_surf_single, SurfaceAtlas))	_type = VALUE_TYPE.atlas;
		else if(is_instanceof(_surf_single, __d3dMaterial))	_type = VALUE_TYPE.d3Material;
		
		if(!open) {
			draw_sprite_stretched(THEME.textbox, 3, _x, _y, _w, _h);
			
			if(_type == VALUE_TYPE.surface && hover && hoverRect) {
				draw_sprite_stretched(THEME.textbox, 1, _x, _y, _w, _h);
				if(mouse_press(mb_left, active))
					trigger();
				
				if(mouse_click(mb_left, active))
					draw_sprite_stretched_ext(THEME.textbox, 2, _x, _y, _w, _h, COLORS._main_accent, 1);	
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
			
			var _arrLen = 0;
			var _arrInd = 0;
			
			if(is_array(_surface) && array_length(_surface)) {
				_arrLen  = array_length(_surface);
				_arrInd  = safe_mod(round(current_time / 250), array_length(_surface));
				_surface = _surface[_arrInd];
			}
			
			if(is_instanceof(_surface, __d3dMaterial))
				_surface = _surface.surface;
			
			if(is_surface(_surface)) {
				var sfw = surface_get_width_safe(_surface);	
				var sfh = surface_get_height_safe(_surface);	
				var ss  = min(sw / sfw, sh / sfh);
				var _sx = sx0 + sw / 2 - ss * sfw / 2;
				var _sy = sy0 + sh / 2 - ss * sfh / 2;
				
				draw_surface_ext_safe(_surface, _sx, _sy, ss, ss, 0, c_white, 1);
				
				if(_arrLen) {
					var bxw = sx1 - sx0;
				
					draw_sprite_stretched_ext(THEME.palette_mask, 1, sx0, sy1 - 3, bxw,                           4, COLORS.panel_bg_clear_inner, 1);
					draw_sprite_stretched_ext(THEME.palette_mask, 1, sx0, sy1 - 3, bxw * (_arrInd + 1) / _arrLen, 4, COLORS._main_accent, 1);
				}
			
				var _txt = $"[{max(1, _arrLen)}] {sfw}x{sfh}";
				
				draw_set_text(_f_p4, fa_right, fa_bottom, COLORS._main_text_inner);
				var _tw = string_width(_txt) + ui(6);
				var _th = 14;
				var _nx = sx1 - _tw;
				var _ny = sy1 - _th;
						
				draw_sprite_stretched_ext(THEME.timeline_node, 0, _nx, _ny, _tw, _th, COLORS.panel_bg_clear_inner, 0.85);
				draw_text_add(sx1 - ui(3), sy1 + ui(1), _txt);
			}
			
			draw_set_color(COLORS.widget_surface_frame);
			draw_rectangle(sx0, sy0, sx1 - 1, sy1 - 1, true);
			
			if(_type == VALUE_TYPE.surface)
				draw_sprite_ui_uniform(THEME.scroll_box_arrow, 0, _x + _w - ui(20), _y + _h / 2, 1, COLORS._main_icon);
		}
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _w + ui(6), _h + ui(6), COLORS._main_accent, 1);	
		
		if(DRAGGING && DRAGGING.type == "Asset" && hover && hoverRect) {
			draw_sprite_stretched_ext(THEME.ui_panel_active, 0, _x, _y, _w, _h, COLORS._main_value_positive, 1);	
			if(mouse_release(mb_left))
				onModify(DRAGGING.data.path);
		}
		
		resetFocus();
		
		return h;
	}
}