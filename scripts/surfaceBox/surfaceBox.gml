function surfaceBox(_onModify, _def_path = "") : widget() constructor {
	onModify = _onModify;	
	def_path = _def_path;
	
	open_rx = 0;
	open_ry = 0;
	
	align = fa_center;
	display_data = {};
	current_data = noone;
	
	cb_atlas_crop = new checkBox(function() /*=>*/ { display_data.atlas_crop = !display_data.atlas_crop; });
	
	static trigger = function() {
		dialogPanelCall(new Panel_Asset_Selector(self, def_path), x + open_rx, y + open_ry);
	}
	
	static setInteract = function(_interactable) { 
		interactable = _interactable;
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
		
		var boxx = _x;
		var boxy = _y;
		var boxw = _w;
		var boxh = _h;
		
		var hoverRect = point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h);
		
		var _surf_single = _surface;
		if(is_array(_surf_single) && !array_empty(_surf_single))
			_surf_single = _surf_single[0];
		
		var _arrLen = 0;
		var _arrInd = 0;
		current_data = undefined;
		
		if(is_array(_surface)) {
			if(array_length(_surface)) {
				_arrLen  = array_length(_surface);
				_arrInd  = safe_mod(round(current_time / 250), _arrLen);
				_surface = _surface[_arrInd];
			} else 
				_surface = noone;
		}
		
		if(!is_surface(_surface)) _surface = noone;
		
		var _ars = .5;
		var _arw = sprite_get_width(THEME.scroll_box_arrow) * _ars + ui(8);
		
		if(is(_surface, dynaDraw_canvas)) {
			current_data = _surface;
			boxh = _surface.drawWidget(_x, _y, _w, _h, _m, hover, active, _rx, _ry);
			_h   = boxh; //??
			 h   = boxh; //?? just choose which var to use
			
			hoverRect = point_in_rectangle(_m[0], _m[1], _x + _w - _arw, _y + _h - _arw, _x + _w, _y + _h);
			var _arx = _x + _w - _arw / 2;
			var _ary = _y + _h - _arw / 2;
			
			var cc = ihover && hoverRect? COLORS._main_icon_light : COLORS._main_icon;
			var aa = .4 + .4 * interactable;
			draw_sprite_ui_uniform(THEME.scroll_box_arrow, 0, _arx, _ary, _ars, cc, aa);
			
			if(ihover && hoverRect) {
				draw_sprite_stretched(THEME.textbox, 1, _x + _w - _arw, _y + _h - _arw, _arw, _arw);
				if(mouse_press(mb_left, iactive)) trigger();
			}
			
		} else {
			     if(is(_surface, __d3dMaterial)) _surface = _surface.surface;
			else if(is(_surface, dynaDraw))      _surface = _surface;
			else if(is(_surface, dynaSurf))      _surface = array_safe_get_fast(_surface.surfaces, 0, noone);
			else if(is(_surface, Atlas))         _surface = _surface.getSurface();
			
			var pad = ui(12);
			var sw  = min(_w - pad, _h - pad);
			var sh  = sw;
			
			var sx0 = _x + _w / 2 - sw / 2;
			var sx1 = sx0 + sw;
			var sy0 = _y + _h / 2 - sh / 2;
			var sy1 = sy0 + sh;
			
			draw_sprite_stretched(THEME.textbox, 3, _x, _y, _w, _h);
			
			current_data = _surface;
			ui_rect(sx0, sy0, sx1, sy1, COLORS.widget_surface_frame);
			
			if(is(_surface, dynaDraw)) {
				_surface.draw(sx0 + sw / 2, sy0 + sh / 2, sw - 2, sh - 2);
				
				gpu_set_texfilter(true);
				draw_sprite_ui(THEME.dynadraw, 0, sx0 + sw - ui(10), sy0 + sh - ui(10), .75, .75);
				gpu_set_texfilter(false);
				
			} else if(surface_exists(_surface)) {
				var sfw = surface_get_width(_surface);	
				var sfh = surface_get_height(_surface);	
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
				
				draw_sprite_stretched_ext(THEME.ui_panel, 0, _nx, _ny, _tw, _th, COLORS.panel_bg_clear_inner, 0.85);
				draw_text_add(sx1 - ui(3), sy1 + ui(1), _txt);
			}
			
			var _arx = _x + _w - _arw / 2;
			var _ary = _y + _h / 2;
			var cc = ihover && hoverRect? COLORS._main_icon_light : COLORS._main_icon;
			var aa = .4 + .4 * interactable;
			draw_sprite_stretched_ext(THEME.textbox, 3, _x + _w - _arw, _y, _arw, _h, CDEF.main_mdwhite, 1);
			draw_sprite_ui_uniform(THEME.scroll_box_arrow, 0, _arx, _ary, _ars, cc, aa);
			
			draw_sprite_stretched_ext(THEME.textbox, 0, boxx, boxy, boxw, boxh);
			if(ihover && hoverRect) {
				draw_sprite_stretched(THEME.textbox, 1, boxx, boxy, boxw, boxh);
				if(mouse_press(mb_left, iactive)) trigger();
			}
		}	
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _w + ui(6), _h + ui(6), COLORS._main_accent, 1);	
		
		if(DRAGGING && DRAGGING.type == "Asset" && hover && hoverRect) {
			draw_sprite_stretched_ext(THEME.ui_panel, 1, _x, _y, _w, _h, COLORS._main_value_positive, 1);	
			if(mouse_release(mb_left))
				onModify(DRAGGING.data.path);
		}
		
		if(is(_surface, dynaDraw)) {
			var _eds = _surface.editors;
			var _hg  = line_get_height(f_p3, 6);
			
			h += ui(4);
			var yy = y + h;
			
			for( var i = 0, n = array_length(_eds); i < n; i++ ) {
				var _ed  = _eds[i];
				var _txt = _ed[0];
				var _wid = _ed[1];
				var _val = _ed[2]();
				
				draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
				draw_text_add(_x, yy + _hg / 2, _txt);
				
				var _tw  = max(string_width(_txt) + ui(16), _w * .3);
				var _par = new widgetParam(_x + _tw, yy, _w - _tw, _hg, _val, {}, _m, _rx, _ry).setFont(f_p3);
				_par.s = _hg;
				if(is(_wid, checkBox)) _par.halign = fa_center;
				
            	_wid.setFocusHover(active, hover);
				_hg = _wid.drawParam(_par);
				
				yy += _hg + ui(4);
				 h += _hg + ui(4);
			}
			
			h -= ui(4);
		}
		
		resetFocus();
		return h;
	}
	
	static clone = function() /*=>*/ {return new surfaceBox(onModify, def_path)};
}