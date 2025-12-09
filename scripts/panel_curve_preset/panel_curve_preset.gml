function Panel_Curve_Presets(_curve, _onModify = undefined) : PanelContent() constructor {
	title = "Curve Preset";
	w = ui(400);
	h = ui(480);
	
	curve    = _curve;
	onModify = _onModify;
	context  = array_empty(CURVES_FOLDER.subDir)? CURVES_FOLDER : CURVES_FOLDER.subDir[0];
	
	function gotoDir(dirName) {
		for(var i = 0; i < array_length(CURVES_FOLDER.subDir); i++) {
			var d = CURVES_FOLDER.subDir[i];
			if(d.name != dirName) continue;
			
			d.open = true;
			setContext(d);
		}
	}
	
	function setContext(cont) {
		context = cont;
		contentPane.scroll_y_raw = 0;
		contentPane.scroll_y_to	 = 0;
	}

	folderW = ui(140);
	folderW_dragging = false;
	folderW_drag_mx  = 0;
	folderW_drag_sx  = 0;
	
	content_w = w - ui(26) - folderW;
	content_h = h - ui(24);
	
	folderPane = new scrollPane(folderW - ui(12), content_h - ui(32), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		var hh = ui(8);
		var ww = folderPane.surface_w;
		var hg = line_get_height(f_p2, 5);
		
		var _hov = pHOVER && point_in_rectangle(_m[0], _m[1], 0, _y, ww, _y + hg);
		if(_hov) {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, _y, ww, hg, CDEF.main_ltgrey, 1);
			if(mouse_lpress(pFOCUS)) setContext(CURVES_FOLDER);
				
		} else
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, _y, ww, hg, CDEF.main_white, 1);
		
		draw_set_text(f_p3, fa_center, fa_center, context == CURVES_FOLDER? COLORS._main_accent : COLORS._main_text_sub);
		draw_text_add(ww / 2, _y + hg / 2, __txt("Root"));
		
		hh += hg;
		_y += hg;
		
		for(var i = 0; i < array_length(CURVES_FOLDER.subDir); i++) {
			hg = CURVES_FOLDER.subDir[i].draw(self, 0, _y, _m, ww, pHOVER, pFOCUS, CURVES_FOLDER);
			hh += hg;
			_y += hg;
		}
		
		folderPane.hover_content = true;
		return hh + 8;
	});
	folderPane.scroll_color_bg = CDEF.main_mdblack;
	
	contentPane = new scrollPane(content_w, content_h, function(_y, _m) {
		DRAW_CLEAR
		
		var amo = array_length(context.content);
		var sw  = contentPane.surface_w;
		var sh  = contentPane.surface_h;
		var hg  = ui(80);
		var hh  = ui(8) + amo * (hg + 4);
		
		var pd = ui(6);
		var xx = ui(8);
		var yy = ui(8) + _y;
		var ww = sw - ui(8);
		
		for( var i = 0, n = array_length(context.content); i < n; i++ ) {
			var c = context.content[i];
			if(c.content == undefined)
				c.content = json_load_struct(c.path, 0);
		
			if(yy + hg + ui(4) < -ui(8)) {
				yy += hg + ui(4);
				continue;
			}
			
			if(yy > sh + ui(8)) break;
			
			var _name = c.name;
			var _curv = c.content;
			if(!is_array(_curv)) continue;
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, xx, yy, ww, hg);
			
			draw_set_text(f_p4, fa_left, fa_top, COLORS._main_text);
			draw_text_add(xx + pd + ui(4), yy + pd - ui(2), _name);
			
			var cx = xx + pd;
			var cy = yy + pd + ui(16);
			var cw = ww - pd * 2;
			var ch = hg - pd * 2 - ui(16);
			
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, cx, cy, cw, ch);
			draw_set_color(COLORS._main_icon);
			draw_curve(cx, cy, cw, ch, _curv);
			
			if(pHOVER && contentPane.hover && point_in_rectangle(_m[0], _m[1], xx, yy, xx + ww, yy + hg)) {
				draw_sprite_stretched_ext(THEME.ui_panel, 1, xx, yy, ww, hg, COLORS._main_accent, 1);
				contentPane.hover_content = true;
				
				if(mouse_press(mb_left, pFOCUS)) {
					onModify(_curv);
					close();
				}
			}
			
			yy += hg + ui(4);
		}
		
		return hh + ui(16);
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
		draw_text(ui(24), pad + ui(18), __txt("Curves"));
		
		#region buttons
			var m = [mx,my];
			
			var bb = THEME.button_hide_fill;
			var bs = ui(24);
			var bx = pad + folderW - bs - ui(12);
			var by = pad + ui(18) - bs / 2;
			
			var cc = COLORS._main_value_positive;
			if(buttonInstant_Pad(bb, bx, by, bs, bs, m, pHOVER, pFOCUS, "Add to Preset", THEME.add, 0, cc, 1, ui(6)) == 2) {
				fileNameCall(context.path, function(f) /*=>*/ {
					if(f == "") return;
					
					f = filename_ext_verify(f, ".json");
					json_save_struct(f, curve);
					context.scan([".json"]);
				});
				
			} bx -= bs + ui(1);
			
			var cc = COLORS._main_icon;
			if(buttonInstant_Pad(bb, bx, by, bs, bs, m, pHOVER, pFOCUS, "New Folder", THEME.dFolder_add, 0, cc, 1, ui(2)) == 2) {
				fileNameCall(context.path, function(f) /*=>*/ {
					if(f == "") return;
					
					directory_create(f);
					context.scan([".json"]);
				});
				
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