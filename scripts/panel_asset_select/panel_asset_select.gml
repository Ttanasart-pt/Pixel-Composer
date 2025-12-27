function Panel_Asset_Selector(_target, _defPath) : PanelContent() constructor {
	title = "Assets";
	w = ui(632);
	h = ui(360);
		
	target  = _target;
	context = global.ASSETS;
	
	function gotoDir(dirName) {
		for(var i = 0; i < array_length(global.ASSETS.subDir); i++) {
			var d = global.ASSETS.subDir[i];
			if(d.name != dirName) continue;
			
			d.open = true;
			setContext(d);
		}
	}
	gotoDir(_defPath);
	
	function setContext(cont) {
		context = cont;
		contentPane.scroll_y_raw = 0;
		contentPane.scroll_y_to	 = 0;
	}
	
	folderW = ui(160);
	folderW_dragging = false;
	folderW_drag_mx  = 0;
	folderW_drag_sx  = 0;
	
	content_w = w - ui(26) - folderW;
	content_h = h - ui(24);
	
	folderPane = new scrollPane(1, 1, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		var hh = ui(8);
		var ww = folderPane.surface_w;
		var hg = line_get_height(f_p2, 5);
		
		var _hov = pHOVER && point_in_rectangle(_m[0], _m[1], 0, _y, ww, _y + hg);
		if(_hov) {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, _y, ww, hg, CDEF.main_ltgrey, 1);
			if(mouse_lpress(pFOCUS)) setContext(global.ASSETS);
				
		} else
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, _y, ww, hg, CDEF.main_white, 1);
		
		draw_set_text(f_p3, fa_center, fa_center, context == global.ASSETS? COLORS._main_accent : COLORS._main_text_sub);
		draw_text_add(ww / 2, _y + hg / 2, __txt("Root"));
		
		hh += hg;
		_y += hg;
		
		hg = DYNADRAW_FOLDER.draw(self, 0, _y, _m, ww, pHOVER, pFOCUS, global.ASSETS);
		hh += hg;
		_y += hg;
		
		for(var i = 0; i < array_length(global.ASSETS.subDir); i++) {
			hg = global.ASSETS.subDir[i].draw(self, 0, _y, _m, ww, pHOVER, pFOCUS, global.ASSETS);
			hh += hg;
			_y += hg;
		}
		
		folderPane.hover_content = true;
		return hh + 8;
	});
	folderPane.scroll_color_bg = CDEF.main_mdblack;
	
	contentPane = new scrollPane(1, 1, function(_y, _m) {
		draw_clear_alpha(c_white, 0);
		
		var hov = contentPane.hover;
		var foc = contentPane.active;
		
		var contents = context.content;
		var amo   = array_length(contents);
		var hh    = 0;
		var surfh = contentPane.surface_h + 4;
		var frame = current_time * PREFERENCES.collection_preview_speed / 8000;
		
		var grid_size  = ui(64);
		var img_size   = grid_size - ui(16);
		var grid_space = ui(6);
		var col = max(1, floor(contentPane.surface_w / (grid_size + grid_space)));
		var row = ceil(amo / col);
		var yy  = _y + grid_space;
		var hght = grid_size + grid_space;
		
		hh += grid_space + hght * row;
		
		for(var i = 0; i < row; i++) {
			if(yy + grid_size < -4) { yy += hght; continue; }
			if(yy > surfh) break;
			
			for(var j = 0; j < col; j++) {
				var index = i * col + j;
				if(index >= amo) break;
				
				var content = contents[index];
				var xx = grid_space + (grid_size + grid_space) * j;
				
				BLEND_OVERRIDE
				draw_sprite_stretched_ext(THEME.node_bg, 0, xx, yy, grid_size, grid_size, COLORS.node_base_bg);
				BLEND_ADD
				draw_sprite_stretched_ext(THEME.node_bg, 1, xx, yy, grid_size, grid_size, COLORS._main_icon, .25);
				BLEND_NORMAL
				
				var spr = -1;
				
				if(is(content, dynaDraw_canvas)) {
					var ss = img_size / 64;
					var sx = xx + grid_size / 2;
					var sy = yy + grid_size / 2;
					
					draw_sprite_ext(s_node_canvas, frame, sx, sy, ss, ss, 0, c_white, 1);
					
				} else if(is(content, dynaSurf)) {
					var _sw = grid_size - ui(16);
					var _sh = grid_size - ui(16);
					
					var sx = xx + grid_size / 2;
					var sy = yy + grid_size / 2;
					content.draw(sx, sy, _sw, _sh);
					draw_sprite_ui(THEME.dynadraw, 0, xx + grid_size - ui(14), yy + grid_size - ui(14));
					
				} else {
					spr = content.getSpr();
					
					if(sprite_exists(spr)) {
						var sw = sprite_get_width(spr);
						var sh = sprite_get_height(spr);
						var ss = img_size / max(sw, sh);
						var sx = xx + (grid_size - sw * ss) / 2;
						var sy = yy + (grid_size - sh * ss) / 2;
						var sn = sprite_get_number(spr);
						
						draw_sprite_ext(spr, frame, sx, sy, ss, ss, 0, c_white, 1);
						
						var _txt = $"{sw}x{sh}";
						if(sn) _txt = $"[{sn}] " + _txt;
						
						draw_set_text(_f_p4, fa_right, fa_bottom, COLORS._main_text_inner);
						var _tw = string_width(_txt) + ui(6);
						var _th = 14;
						var _nx = xx + grid_size - 1 - _tw;
						var _ny = yy + grid_size - _th;
						
						draw_sprite_stretched_ext(THEME.ui_panel, 0, _nx, _ny, _tw, _th - 1, COLORS.panel_bg_clear_inner, 0.85);
						draw_text_add(xx + grid_size - ui(3), yy + grid_size - ui(2), _txt);
						
					} else if(spr == -1) {
						var _rr = lerp(.075, .2, abs(dsin(current_time / 2)));
						draw_circle_ui(xx + grid_size / 2, yy + grid_size / 2, grid_size * .25, _rr, COLORS._main_icon, 1);
					}
				}
				
				if(target.interactable && hov && point_in_rectangle(_m[0], _m[1], xx, yy, xx + grid_size, yy + grid_size)) {
					contentPane.hover_content = true;
					TOOLTIP = [ spr, "sprite" ];
					
					draw_sprite_stretched_ext(THEME.node_bg, 1, xx, yy, grid_size, grid_size, COLORS._main_accent, 1);
					
					if(mouse_press(mb_left, foc)) {
						if(is(content, dynaSurf)) 
							target.onModify(content.clone());
						else 
							target.onModify(content.path);
							
						close();
					}
				}
			}
			
			yy += hght;
		}
		
		return hh;
	});

	function drawContent(panel) {
		if(folderW_dragging) {
			var _w = folderW_drag_sx + (mx - folderW_drag_mx);
			_w = clamp(_w, ui(128), w - ui(128));
			
			folderW = _w;
			onResize();
			
			if(mouse_release(mb_left)) 
				folderW_dragging = -1;
		}
		
		var pad = ui(8);
		
		draw_set_text(f_p0b, fa_left, fa_center, COLORS._main_text);
		draw_text(ui(16), pad + ui(16), __txt("Assets"));
		
		#region buttons
			var m = [mx,my];
			
			var bb = THEME.button_hide_fill;
			var bs = ui(24);
			var bx = pad + folderW - bs - ui(12);
			var by = pad + ui(18) - bs / 2;
			
			var iss = is_surface(target.current_data) && context != DYNADRAW_FOLDER;
			
			var cc = iss? COLORS._main_value_positive : COLORS._main_icon_dark;
			if(buttonInstant_Pad(bb, bx, by, bs, bs, m, iss && pHOVER, pFOCUS, "Add to Asset", THEME.add, 0, cc, 1, ui(6)) == 2) {
				fileNameCall(context.path, function(f) /*=>*/ {
					if(f == "") return;
					
					f = filename_ext_verify(f, ".png");
					surface_save_safe(target.current_data, f);
					context.scan([".png"]);
				});
				
			} bx -= bs + ui(1);
			
			var cc = COLORS._main_icon;
			if(buttonInstant_Pad(bb, bx, by, bs, bs, m, pHOVER, pFOCUS, "New Folder", THEME.dFolder_add, 0, cc, 1, ui(2)) == 2) {
				fileNameCall(context.path, function(f) /*=>*/ {
					if(f == "") return;
					
					directory_create(f);
					context.scan([".png"]);
				});
				
			} bx -= bs + ui(1);
			
			var cc = COLORS._main_icon;
			if(buttonInstant_Pad(bb, bx, by, bs, bs, m, pHOVER, pFOCUS, "Open Explorer", THEME.dPath_open, 0, cc, 1, ui(2)) == 2) {
				shellOpenExplorer(context.path);
			} bx -= bs + ui(1);
		#endregion
		
		content_w = w - pad * 2 - ui(2) - folderW;
		content_h = h - pad * 2;
		
		folderPane.setFocusHover(pFOCUS, pHOVER);
		folderPane.verify(folderW - pad, content_h - ui(36));
		folderPane.drawOffset(pad, pad + ui(36), mx, my);
		
		var _cnt_x = pad + folderW - ui(4);
		var dx0 = _cnt_x - ui(8);
		var dx1 = _cnt_x;
		var dy0 = ui(48);
		var dy1 = h - ui(16);
		
		if(point_in_rectangle(mx, my, dx0, dy0, dx1, dy1)) {
			CURSOR = cr_size_we;
			if(mouse_click(mb_left, pFOCUS)) {
				folderW_dragging = true;
				folderW_drag_mx  = mx;
				folderW_drag_sx  = folderW;
			}
		}
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, _cnt_x, pad, content_w + pad - ui(6), h - pad * 2);
		
		contentPane.setFocusHover(pFOCUS, pHOVER);
		contentPane.verify(content_w, content_h - 2);
		contentPane.drawOffset(_cnt_x, pad + 1, mx, my);
	}
}