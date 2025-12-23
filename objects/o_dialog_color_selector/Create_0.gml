/// @description init
event_inherited();
PALETTES_FOLDER.forEach(function(f) /*=>*/ { if(f.content == undefined) f.content = loadPalette(f.path); }); // Load all presets

#region data
	dialog_w = ui(812);
	dialog_h = ui(396);
	title_height = 52;
	interactable = true;
	destroy_on_click_out = true;
	
	name = __txtx("color_selector_title", "Color selector");
	
	previous_color = c_black;
	selector       = new colorSelector();
	drop_target    = noone;
	
	function setApply(_onApply) { onApply = _onApply; selector.onApply = _onApply; return self; }
	function setDefault(color) { selector.setColor(color); previous_color = color; return self; }
	
	b_cancel = button(function() /*=>*/ { onApply(previous_color); instance_destroy(); }).setIcon(THEME.undo, 0, COLORS._main_icon)
	                                                                         .setTooltip(__txtx("dialog_revert_and_exit", "Revert and exit"));
	b_apply  = button(function() /*=>*/ { onApply(selector.current_color); instance_destroy(); }).setIcon(THEME.accept, 0, COLORS._main_icon_dark);
#endregion

#region presets
	preset_show_name = true;
	preset_selecting = undefined;
	preset_expands   = {};
	
	pal_padding    = ui(9);
	sp_preset_w    = ui(240) - pal_padding * 2 - ui(8);
	sp_preset_size = ui(20);
	click_block    = false;
	
	function drawPaletteDirectory(_dir, _x, _y, _m) {
		var _hov = sp_presets.hover;
		var _foc = sp_presets.active && interactable;
		
		var ww  = sp_presets.surface_w - _x;
		var pd  = ui(2);
		var nh  = preset_show_name? ui(20) : pd;
		
		var _gs = sp_preset_size;
		var  hh = 0;
		
		var _ww = ww - pd * 2;
		var _bh = nh + _gs + pd;
		var col = max(1, floor(_ww / _gs)), row;
		
		var _exp, _height, pre_amo, _palRes;
		
		var lbh = ui(20);
		var sch = search_string != "";
		
		var bs = lbh - ui(4);
		var fav = undefined;
		
		for( var i = 0, n = array_length(_dir.subDir); i < n; i++ ) {
			var _sub  = _dir.subDir[i];
			var _open = sch || (_sub[$ "expanded"] ?? true);
			if(_sub.name == "Mixer") continue;
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, _x, _y, ww, lbh);
			if(!sch && _hov && point_in_rectangle(_m[0], _m[1], _x, _y, _x + ww, _y + lbh)) {
				draw_sprite_stretched_ext(THEME.node_bg, 1, _x, _y, ww, lbh, COLORS._main_icon, 1);
				if(mouse_lpress(_foc)) {
					_open = !_open;
					_sub[$ "expanded"] = _open;
				}
			}
			
			draw_sprite_ui_uniform(THEME.arrow, _open * 3, _x + ui(12), _y + lbh/2, .8, COLORS._main_icon);
			var _tx = _x + ui(24);
			if(_sub.path == "Favorites") {
				draw_sprite_ui_uniform(THEME.favorite, 1, _tx + ui(4), _y + lbh/2, .5, CDEF.yellow, 1);
				_tx += ui(12);
			}
			draw_set_text(f_p4, fa_left, fa_center, COLORS._main_text);
			draw_text_add(_tx, _y + lbh/2, _sub.name);
			
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
			
			if(sch && string_pos(search_string, string_lower(_name)) == 0) continue;
			if(!is_array(_palt)) continue;
			
			pre_amo  = array_length(_palt);
			row      = ceil(pre_amo / col);
			_exp     = preset_expands[$ _path] || row <= 1;
			_height  = _exp? nh + row * _gs + pd : _bh;
			
			var isHover = _hov && point_in_rectangle(_m[0], _m[1], _x, _y, _x + ww, _y + _height);
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, _x, _y, ww, _height);
			if(isHover) {
				draw_sprite_stretched_ext(THEME.ui_panel, 1, _x, _y, ww, _height, COLORS._main_accent, 1);
				sp_presets.hover_content = true;
			}
			
			if(preset_show_name) {
				draw_sprite_ui(THEME.arrow, _exp * 3, _x + ui(8), _y + nh / 2, .75, .75, 0, COLORS._main_text_sub);
				draw_set_text(f_p4, fa_left, fa_top, COLORS._main_text);
				draw_text_add(_x + ui(16), _y + ui(2), _name);
				
				var bx = _x + ww - ui(2) - bs;
				var by = _y + ui(2);
				
				var bt = __txt("Favorite");
				var bc = p.fav? CDEF.yellow : COLORS._main_icon;
				var b  = buttonInstant_Pad(noone, bx, by, bs, bs, _m, _hov, _foc, bt, THEME.favorite, p.fav, bc, .85);
				if(b) isHover = false; 
				if(b == 2) fav = p;
				bx -= bs + 1;
			}
			
			var _hoverColor = noone;
			if(_exp) {
				_palRes     = drawPaletteGrid(_palt, _x + pd, _y + nh, _ww, _gs, { color : selector.current_color, mx : _m[0], my : _m[1] });
				_hoverColor = _palRes.hoverIndex > noone? _palRes.hoverColor : noone;
				
			} else drawPalette(_palt, _x + pd, _y + nh, _ww, _gs);
			
			if(_hoverColor != noone) {
				var _box = _palRes.hoverBBOX;
				draw_sprite_stretched_ext(THEME.box_r2, 1, _box[0], _box[1], _box[2], _box[3], c_white);
			}
			
			if(!click_block && _foc) {
				if(mouse_click(mb_left)) {
					if(_hoverColor != noone) {
						selector.setColor(_hoverColor);
						
					} else if(isHover) {
						preset_expands[$ _path] = !_exp;
						preset_selecting = _palt;
						click_block = true;
					}
				}
				
				if(mouse_click(mb_right)) {
					if(_hoverColor != noone) {
						menuCall("palette_window_preset_menu", [
							menuItem(__txtx("palette_mix_color", "Mix Color"), function(c) /*=>*/ { selector.setMixColor(c); }).setParam(_hoverColor),
						]);
						
					} else if(isHover) {
						menuCall("palette_window_preset_menu", [
							menuItem(__txtx("palette_editor_set_default", "Set as default"), function(p) /*=>*/ { PROJECT.setPalette(array_clone(p)); }).setParam(_palt),
							menuItem(__txtx("palette_editor_delete",      "Delete palette"), function(p) /*=>*/ { file_delete(p); __initPalette(); }).setParam(_path),
						]);
					}
				}
			}
			
			_y += _height + ui(4);
			hh += _height + ui(4);
		}
		
		if(fav) __togglePaletteFav(fav);
		
		return hh;
	}
	
	sp_presets = new scrollPane(sp_preset_w, dialog_h - ui(48 + 8) - pal_padding, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var hh = drawPaletteDirectory(PALETTES_FOLDER,  0, _y, _m);
		if(mouse_release(mb_left)) click_block = false;
		
		return hh;
	});
	
	//////////////////////// SEARCH ////////////////////////
	
	search_string = "";
	tb_search = textBox_Text(function(t) /*=>*/ { search_string = string_lower(t) } )
	               .setFont(f_p2).setHide(1).setEmpty(false).setPadding(ui(24)).setAutoUpdate();
	
	////////////////////////  SORT  ////////////////////////
	
	function sortPalettePreset(fn, _sub = false) {
		array_remove(PALETTES_FOLDER.subDir, PALETTES_FAV_DIR);
		PALETTES_FAV_DIR.sort(fn);
		PALETTES_FOLDER.sort(fn, _sub, true);
		array_insert(PALETTES_FOLDER.subDir, 0, PALETTES_FAV_DIR);
	}
	
	sortPreset_name_a = function() /*=>*/ { sortPalettePreset(function(p0, p1) /*=>*/ {return string_compare(p0.name, p1.name)}, true); }
	sortPreset_name_d = function() /*=>*/ { sortPalettePreset(function(p0, p1) /*=>*/ {return string_compare(p1.name, p0.name)}, true); }
	
	sortPreset_size_a = function() /*=>*/ { sortPalettePreset(function(p0, p1) /*=>*/ { return array_length(p0.content) - array_length(p1.content); }); }
	sortPreset_size_d = function() /*=>*/ { sortPalettePreset(function(p0, p1) /*=>*/ { return array_length(p1.content) - array_length(p0.content); }); }
	
	sortPreset_hue_a  = function() /*=>*/ { sortPalettePreset(function(p0, p1) /*=>*/ {return palette_compare_hue_var(p0.content, p1.content)}); }
	sortPreset_hue_d  = function() /*=>*/ { sortPalettePreset(function(p0, p1) /*=>*/ {return palette_compare_hue_var(p1.content, p0.content)}); }
	
	sortPreset_sat_a  = function() /*=>*/ { sortPalettePreset(function(p0, p1) /*=>*/ {return palette_compare_sat(p0.content, p1.content)}); }
	sortPreset_sat_d  = function() /*=>*/ { sortPalettePreset(function(p0, p1) /*=>*/ {return palette_compare_sat(p1.content, p0.content)}); }
	
	sortPreset_val_a  = function() /*=>*/ { sortPalettePreset(function(p0, p1) /*=>*/ {return palette_compare_val(p0.content, p1.content)}); }
	sortPreset_val_d  = function() /*=>*/ { sortPalettePreset(function(p0, p1) /*=>*/ {return palette_compare_val(p1.content, p0.content)}); }
	
	menu_preset_sort = [
		menuItem(__txt("Display Name"), function() /*=>*/ { preset_show_name = !preset_show_name; }, noone, noone, function() /*=>*/ {return preset_show_name}),
		-1,
		new MenuItem_Sort(__txt("Name"), [ sortPreset_name_a, sortPreset_name_d ]),
		new MenuItem_Sort(__txt("Size"), [ sortPreset_size_a, sortPreset_size_d ]),
		-1,
		new MenuItem_Sort(__txt("Hue Flex"),    [ sortPreset_hue_a,  sortPreset_hue_d ]),
		new MenuItem_Sort(__txt("Sat Average"), [ sortPreset_sat_a,  sortPreset_sat_d ]),
		new MenuItem_Sort(__txt("Val Average"), [ sortPreset_val_a,  sortPreset_val_d ]),
	];
#endregion

#region action
	function checkMouse() {}
#endregion