function materialBox(_onModify) : widget() constructor {
	onModify = _onModify;	
	align    = fa_center;
	defMat   = new __d3dMaterial();
	currMat  = defMat;
	
	sb_filtering = new scrollBox(["Pixel", "Bilinear"], function(val) { currMat.texFilter = val; onModify(currMat); })
	
	for(var i = 0; i < 5; i++) tb[i] = new textBox(TEXTBOX_INPUT.number, noone).setSlidable();
	
	tb[0].onModify = function(val) { currMat.diffuse    = val; onModify(currMat); }
	tb[1].onModify = function(val) { currMat.specular   = val; onModify(currMat); }
	tb[2].onModify = function(val) { currMat.metalic    = val; onModify(currMat); }
	tb[3].onModify = function(val) { currMat.shine      = val; onModify(currMat); }
	tb[4].onModify = function(val) { currMat.reflective = val; onModify(currMat); }
	
	tb[0].setLabel("diffuse");
	tb[1].setLabel("specular");
	tb[2].setLabel("metalic");
	tb[3].setLabel("shine");
	tb[4].setLabel("reflective");
	
	static setInteract = function(interactable) { #region
		self.interactable = interactable;
		
		//sb_filtering.interactable = true;
		//for( var i = 0; i < array_length(tb); i++ ) 
		//	tb[i].interactable = true;
	} #endregion
	
	static register = function(parent = noone) { #region
		//sb_filtering.register(parent);
		//for( var i = 0; i < array_length(tb); i++ ) 
		//	tb[i].register(parent);
	} #endregion
	
	static drawParam = function(params) { #region
		setParam(params);
		//sb_filtering.setParam(params);
		//for(var i = 0; i < array_length(tb); i++) 
		//	tb[i].setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.display_data, params.m, params.rx, params.ry);
	} #endregion
	
	static draw = function(_x, _y, _w, _h, _surface, _display_data, _m, _rx, _ry) { #region
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		//h = _h + (TEXTBOX_HEIGHT + ui(4)) * 4;
		open_rx = _rx;
		open_ry = _ry;
		
		if(is_array(_surface) && array_empty(_surface)) return h;
		
		var yy = y;
		
		#region draw surface
		
			draw_sprite_stretched(THEME.textbox, 3, _x, _y, _w, _h);
			draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _w, _h, c_white, 0.5 + 0.5 * interactable);
			
			var pad = ui(12);
			var sw  = min(_w - pad, _h - pad);
			var sh  = sw;
		
			var sx0 = _x + _w / 2 - sw / 2;
			var sx1 = sx0 + sw;
			var sy0 = _y + _h / 2 - sh / 2;
			var sy1 = sy0 + sh;
			
			var _arrLen  = is_array(_surface)? array_length(_surface) : 0;
			var _arrInd  = is_array(_surface)? safe_mod(round(current_time / 250), array_length(_surface)) : 0;
			    _surface = is_array(_surface)? _surface[_arrInd] : _surface;
			
			currMat  = is_instanceof(_surface, __d3dMaterial)? _surface : defMat;
			_surface = struct_try_get(currMat, "surface");
			
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
			
			yy = sy1 + ui(10);
		 #endregion
		
		//var tbw = _w / 2 - ui(2);
		//var tbh = TEXTBOX_HEIGHT;
		
		//draw_set_text(font, fa_left, fa_center, COLORS._main_text_sub);
		//var txt = "Interpolation";
		//var lbw = string_width(txt) + ui(16);
		//draw_text_add(_x, yy + tbh / 2, txt);
		
		//sb_filtering.setFocusHover(iactive, ihover);
		//sb_filtering.draw(_x + lbw, yy, _w - lbw, tbh, currMat.texFilter,  _m, _rx, _ry);
		//yy += TEXTBOX_HEIGHT + ui(4);
		
		//for(var i = 0; i < array_length(tb); i++) 
		//	tb[i].setFocusHover(iactive, ihover);
			
		//tb[0].draw(_x,               yy, tbw, tbh, currMat.diffuse,  _m);
		//tb[1].draw(_x + tbw + ui(4), yy, tbw, tbh, currMat.specular, _m);
		//yy += TEXTBOX_HEIGHT + ui(4);
		
		//tb[2].draw(_x,               yy, tbw, tbh, currMat.metalic,  _m);
		//tb[3].draw(_x + tbw + ui(4), yy, tbw, tbh, currMat.shine,    _m);
		//yy += TEXTBOX_HEIGHT + ui(4);
		
		//tb[4].draw(_x,               yy, _w, tbh, currMat.reflective,  _m);
		
		resetFocus();
		
		return h;
	} #endregion
	
	static clone = function() { #region
		var cln = new materialBox(onModify);
		
		return cln;
	} #endregion
}