function Panel_Palette() : PanelContent() constructor {
	title = __txt("Palettes");
	
	w = ui(320);
	h = ui(480);
	
	grid_size    = ui(16);
	grid_size_to = ui(16);
	
	color_dragging = noone;
	drag_from_self = false;
	
	preset_expands = {};
	__save_palette_data = [];
	view_label = true;
	
	paletteParam = { color: c_white, stretch : PREFERENCES.palette_stretch, mx : 0, my : 0 };
	
	menu_refresh = menuItem(__txt("Refresh"), function() /*=>*/ {return __initPalette()});
	menu_add     = menuItemShelf(__txt("Add"), function(_dat) /*=>*/ {
		return submenuCall(_dat, [
			menuItem(__txt("File..."), function() /*=>*/ {
				var _p = get_open_filename_compat("hex|*.hex|gpl|*.gpl|Image|.png", "palette");
				if(!file_exists_empty(_p)) return;
				
				file_copy(_p, $"{DIRECTORY}Palettes/{filename_name(_p)}");
				__initPalette();
			}),
			
			menuItem(__txt("Lospec..."), function() /*=>*/ {
				fileNameCall("", function(txt) /*=>*/ { addPalette_LoSpec(txt); }).setName("Palette")
			}),
		]);
	});
	
	menu_stretch = menuItem(__txt("Stretch"), function() /*=>*/ { PREFERENCES.palette_stretch = !PREFERENCES.palette_stretch; }, noone, noone, function() /*=>*/ {return PREFERENCES.palette_stretch});
	menu_mini    = menuItem(__txt("Label"),   function() /*=>*/ { view_label = !view_label; }, noone, noone, function() /*=>*/ {return view_label});
	  
	function onResize() {
		sp_palettes.resize(w - padding * 2, h - padding * 2);
	}
	
	function drawPaletteDirectory(_dir, _x, _y, _m) {
		var _hov = sp_palettes.hover;
		var _foc = sp_palettes.active;
		
		var ww  = sp_palettes.surface_w - _x;
		var _gs = grid_size;
		var hh  = 0;
		var nh  = ui(20);
		var pd  = ui(2);
		var _ww = ww - pd * 2;
		var _bh = nh + _gs + pd;
		var col = max(1, floor(_ww / _gs)), row, _exp;
		var _height, pre_amo, _palRes;
		
		var lbh = ui(20);
		
		for( var i = 0, n = array_length(_dir.subDir); i < n; i++ ) {
			var _sub  = _dir.subDir[i];
			var _open = _sub[$ "expanded"] ?? true;
			if(_sub.name == "Mixer") continue;
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, _x, _y, ww, lbh);
			if(_hov && point_in_rectangle(_m[0], _m[1], _x, _y, _x + ww, _y + lbh)) {
				draw_sprite_stretched_ext(THEME.node_bg, 1, _x, _y, ww, lbh, COLORS._main_icon, 1);
				if(mouse_lpress(_foc)) {
					_open = !_open;
					_sub[$ "expanded"] = _open;
				}
			}
			
			draw_sprite_ui_uniform(THEME.arrow, _open * 3, _x + ui(12), _y + lbh/2, .8, COLORS._main_icon);
			draw_set_text(f_p4, fa_left, fa_center, COLORS._main_text);
			draw_text_add(_x + ui(24), _y + lbh/2, _sub.name);
			
			hh += lbh + ui(4);
			_y += lbh + ui(4);
			
			if(!_open) continue;
			var _sh  = drawPaletteDirectory(_sub, _x + ui(8), _y, _m);
			
			_y += _sh;
			hh += _sh;
		}
		
		for( var i = 0, n = array_length(_dir.content); i < n; i++ ) {
			var p = _dir.content[i];
			if(p.content == undefined)
				p.content = loadPalette(p.path);
			
			var _name = p.name;
			var _path = p.path;
			var _palt = p.content;
			
			if(!is_array(_palt)) continue;
			
			pre_amo  = array_length(_palt);
			row      = ceil(pre_amo / col);
			_exp     = preset_expands[$ _path] || row <= 1;
			_height  = _exp? nh + row * _gs + pd : _bh;
			
			var isHover = _hov && point_in_rectangle(_m[0], _m[1], _x, _y, _x + ww, _y + _height);
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, _x, _y, ww, _height);
			if(isHover) {
				draw_sprite_stretched_ext(THEME.ui_panel, 1, _x, _y, ww, _height, COLORS._main_accent, 1);
				sp_palettes.hover_content = true;
			}
			
			var cc = COLORS._main_text_sub;
			draw_sprite_ui(THEME.arrow, _exp * 3, _x + ui(8), _y + nh / 2, .75, .75, 0, COLORS._main_text_sub);
			draw_set_text(f_p3, fa_left, fa_top, cc);
			draw_text_add(_x + ui(16), _y + ui(2), _name);
			
			if(i == -1) { draw_set_color(cc); draw_circle_prec(_x + ww - ui(10), _y + ui(10), ui(4), false); }
			
			var _hoverColor = noone;
			if(_exp) {
				_palRes     = drawPaletteGrid(_palt, _x + pd, _y + nh, _ww, _gs, paletteParam);
				_hoverColor = _palRes.hoverIndex > noone? _palRes.hoverColor : noone;
				
			} else drawPalette(_palt, _x + pd, _y + nh, _ww, _gs);
			
			if(_hoverColor != noone) {
				var _box = _palRes.hoverBBOX;
				draw_sprite_stretched_ext(THEME.box_r2, 1, _box[0], _box[1], _box[2], _box[3], c_white);
			}
			
			if(mouse_click(mb_left, _foc)) {
				//
			}
			
			_y += _height + ui(4);
			hh += _height + ui(4);
		}
		
		return hh;
	}
	
	sp_palettes = new scrollPane(w - padding * 2, h - padding * 2, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var ww  = sp_palettes.surface_w;
		var hh  = ui(28);
		var _gs = grid_size;
		var yy  = _y;
		var cur = CURRENT_COLOR;
		var _height;
		
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
		
		if(mouse_release(mb_left)) drag_from_self = false;
		
		paletteParam = { color: cur, stretch : PREFERENCES.palette_stretch, mx : _m[0], my : _m[1] };
		var hh = drawPaletteDirectory(PALETTES_FOLDER, 0, _y, _m);
		
		return hh;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2;
	
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		sp_palettes.setFocusHover(pFOCUS, pHOVER);
		sp_palettes.draw(px, py, mx - px, my - py);
		
		if(pHOVER && key_mod_press(CTRL) && MOUSE_WHEEL != 0)
			grid_size_to = clamp(grid_size_to + ui(4) * MOUSE_WHEEL, ui(8), ui(32));
		grid_size = lerp_float(grid_size, grid_size_to, 10);
		
	}
}