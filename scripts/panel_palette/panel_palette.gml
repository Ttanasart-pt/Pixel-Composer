function Panel_Palette() : PanelContent() constructor {
	title = __txt("Palettes");
	padding = 8;
	
	w = ui(320);
	h = ui(480);
	
	grid_size    = ui(16);
	grid_size_to = ui(16);
	
	color_dragging = noone;
	drag_from_self = false;
	
	__save_palette_data = [];
	view_label = true;
	
	menu_refresh = menuItem(__txt("Refresh"), function() { __initPalette(); });
	menu_add     = menuItem(__txt("Add"), function(_dat) {
		return submenuCall(_dat, [
			menuItem(__txt("File..."), function() {
				var _p = get_open_filename("hex|*.hex|gpl|*.gpl|Image|.png", "palette");
				if(!file_exists_empty(_p)) return;
				
				file_copy(_p, $"{DIRECTORY}Palettes/{filename_name(_p)}");
				__initPalette();
			}),
			menuItem(__txt("Lospec..."), function() {
				fileNameCall("", function(txt) {
					if(txt == "") return;
					txt = string_lower(txt);
					txt = string_replace_all(txt, " ", "-");
					
					var _url = $"https://Lospec.com/palette-list{txt}.json";
					PALETTE_LOSPEC = http_get(_url);
				}).setName("Palette")
			}),
		]);
	}).setIsShelf();
	
	menu_stretch = menuItem(__txt("Stretch"), function() { PREFERENCES.palette_stretch = !PREFERENCES.palette_stretch; }, noone, noone, function() /*=>*/ {return PREFERENCES.palette_stretch});
	menu_mini    = menuItem(__txt("Label"), function() { view_label = !view_label; }, noone, noone, function() /*=>*/ {return view_label});
	  
	function onResize() {
		sp_palettes.resize(w - ui(padding + padding), h - ui(padding + padding));
	}
	
	sp_palettes = new scrollPane(w - ui(padding + padding), h - ui(padding + padding), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var ww  = sp_palettes.surface_w;
		var hh  = ui(28);
		var _gs = grid_size;
		var yy  = _y;
		var cur = CURRENT_COLOR;
		var _height;
		
		if(pHOVER && key_mod_press(CTRL)) {
			if(mouse_wheel_down()) grid_size_to = clamp(grid_size_to - ui(4), ui(8), ui(32));
			if(mouse_wheel_up())   grid_size_to = clamp(grid_size_to + ui(4), ui(8), ui(32));
		}
		grid_size = lerp_float(grid_size, grid_size_to, 10);
		
		if(DRAGGING && DRAGGING.type == "Palette" && !drag_from_self) {
			var _add_h = ui(28);
			var _hov = pHOVER && point_in_rectangle(_m[0], _m[1], 0, yy, ww, yy + _add_h);
			
			draw_sprite_stretched_ext(THEME.ui_panel, 0, 0, yy, ww, _add_h, COLORS._main_value_positive, .4);
			draw_sprite_stretched_ext(THEME.ui_panel, 1, 0, yy, ww, _add_h, COLORS._main_value_positive, .7 + _hov * .25);
			draw_set_text(f_p2, fa_center, fa_center, COLORS._main_value_positive);
			draw_text_add(ww / 2, yy + _add_h / 2, __txt("New palette"));
			
			if(_hov && mouse_release(mb_left)) {
				__save_palette_data = DRAGGING.data;
				
				fileNameCall($"{DIRECTORY}Palettes", function (_path) {
					if(filename_ext(_path) != ".hex") _path += ".hex";
					
					var _str = palette_string_hex(__save_palette_data, false);
					file_text_write_all(_path, _str);
					__initPalette();
				});
			}
			
			yy += _add_h + ui(8);
			hh += _add_h + ui(8);
		}
		
		if(PALETTE_LOSPEC) {
			var _add_h = ui(28);
			var _add_w = ui(64);
			var _add_x = ww / 2 + sin(current_time / 400) * (ww - _add_w) / 2 - _add_w / 2;
			
			draw_sprite_stretched_ext(THEME.ui_panel, 0, 0, yy, ww, _add_h, COLORS._main_value_positive, .4);
			draw_sprite_stretched_ext(THEME.ui_panel, 0, _add_x, yy, _add_w, _add_h, COLORS._main_value_positive, .3);
			draw_sprite_stretched_ext(THEME.ui_panel, 1, 0, yy, ww, _add_h, COLORS._main_value_positive, .7);
			draw_set_text(f_p2, fa_center, fa_center, COLORS._main_value_positive);
			draw_text_add(ww / 2, yy + _add_h / 2, __txt("Loading Lospec Palette..."));
			
			yy += _add_h + ui(8);
			hh += _add_h + ui(8);
		}
		
		if(mouse_release(mb_left)) drag_from_self = false;
		
		var right_clicked = false;
		var pd    = view_label? lerp(ui(4), ui(10), (grid_size - ui(8)) / (ui(32) - ui(8))) : ui(3);
		var param = { color: cur, stretch : PREFERENCES.palette_stretch, mx : _m[0], my : _m[1] };
		var _font = f_p3;
		
		for(var i = 0; i < array_length(PALETTES); i++) {
			var preset	= PALETTES[i];
			var pre_amo = array_length(preset.palette);
			var col     = floor((ww - pd * 2) / _gs);
			var row     = ceil(pre_amo / col);
			
			var _th  = line_get_height(_font);
			var _phh = row * _gs;
			var _height = view_label? _th + _phh + pd : _phh + pd * 2;
			var _paly   = view_label? yy + _th : yy + pd;
			var _palh   = _gs;
			var isHover = pHOVER && point_in_rectangle(_m[0], _m[1], 0, max(0, yy), ww, min(sp_palettes.h, yy + _height));
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, 0, yy, ww, _height);
			if(isHover) draw_sprite_stretched_ext(THEME.node_active, 1, 0, yy, ww, _height, COLORS._main_accent, 1);
			
			var _palRes = drawPaletteGrid(preset.palette, pd, _paly, ww - pd * 2, _palh, param);
			if(view_label) {
				draw_set_text(_font, fa_left, fa_top, COLORS._main_text_sub);
				draw_text_add(pd, yy + ui(2), preset.name);
			}
			
			if(isHover) {
				sp_palettes.hover_content = true;
				
				if(_palRes.hoverIndex > noone) {
					var _box = _palRes.hoverBBOX;
					draw_sprite_stretched_add(THEME.menu_button_mask, 1, _box[0] + 1, _box[1] + 1, _box[2] - 2, _box[3] - 2, c_white, 0.3);
				}
				
				if(mouse_press(mb_left, pFOCUS)) {
					if(_palRes.hoverIndex > noone) {
						CURRENT_COLOR = _palRes.hoverColor;
						
						DRAGGING = {
							type: "Color",
							data: _palRes.hoverColor
						} 
						MESSAGE = DRAGGING;
						
					} else if(point_in_rectangle(_m[0], _m[1], pd, yy, ww - pd, yy + ui(20))) {
						DRAGGING = {
							type: "Palette",
							data: preset.palette
						}
						MESSAGE = DRAGGING;
						drag_from_self = true;
					}
				}
				
				if(mouse_press(mb_right, pFOCUS)) {
					hovering = preset;
					right_clicked = true;
					
					menuCall("palette_window_preset_menu",,, [
						menu_add,
						menu_refresh,
						-1, 
						menuItem(__txtx("palette_editor_set_default", "Set as default"), function() { 
							PROJECT.setPalette(array_clone(hovering.palette));
						}),
						menuItem(__txtx("palette_editor_delete", "Delete palette"), function() { 
							file_delete(hovering.path); 
							__initPalette();
						}),
						-1,
						menu_stretch,
						menu_mini,
					]);
				}
			} 
			
			yy += _height + ui(4);
			hh += _height + ui(4);
		}
		
		if(!right_clicked && mouse_press(mb_right, pFOCUS)) {
			menuCall("palette_window_preset_menu_empty",,, [
				menu_add,
				menu_refresh,
				-1,
				menu_stretch,
				menu_mini,
			]);
		}
		
		return hh;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var px = ui(padding);
		var py = ui(padding);
		var pw = w - ui(padding + padding);
		var ph = h - ui(padding + padding);
	
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		sp_palettes.setFocusHover(pFOCUS, pHOVER);
		sp_palettes.draw(px, py, mx - px, my - py);
		
	}
}