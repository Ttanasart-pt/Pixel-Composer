/// @description init
event_inherited();
PALETTES_FOLDER.forEach(function(f) /*=>*/ { if(f.content == undefined) f.content = loadPalette(f.path); }); // Load all presets

function __PaletteColor(_color = c_black) constructor {
	color = _color;
	x = 0;
	y = 0;
}

#region data
	dialog_w     = ui(812);
	dialog_h     = ui(440);
	title_height = 52;
	destroy_on_click_out = true;
	
	name            = __txtx("palette_editor_title", "Palette editor");
	palette         = 0;
	paletteObject   = [];
	
	index_sel_start = 0;
	index_selecting = [0,0];
	index_dragging  = noone;
	interactable    = true;
	drop_target     = noone; setDrop = function(d) /*=>*/ { drop_target = d; return self; }
	mouse_interact  = false;
	
	mixer           = noone;
	mixer_surface   = noone;
	
	colors_selecting = [];
	
	index_drag_x = 0; index_drag_x_to = 0;
	index_drag_y = 0; index_drag_y_to = 0;
	index_drag_w = 0; index_drag_w_to = 0;
	index_drag_h = 0; index_drag_h_to = 0;
	
	setColor = function(c) /*=>*/ {
		if(index_selecting[1] != 1 || palette == 0) return;
		
		var _ind = index_selecting[0];
		palette[_ind] = c;
		paletteObject[_ind].color = c;
		
		if(onApply != noone) onApply(palette);
	};
	
	onApply  = noone;
	selector = new colorSelector(setColor);
	selector.dropper_close  = false;
	selector.discretize_pal = false;
	
	previous_palette  = c_black;
	selection_surface = noone;
	
	b_cancel = button(function() /*=>*/ { onApply(previous_palette); instance_destroy(); }).setIcon(THEME.undo, 0, COLORS._main_icon)
	                                                                           .setTooltip(__txtx("dialog_revert_and_exit", "Revert and exit"));
	b_apply  = button(function() /*=>*/ { onApply(palette);          instance_destroy(); }).setIcon(THEME.accept, 0, COLORS._main_icon_dark);
	
	menu_add_target = "";
	menu_add = [
		menuItem(__txt("Current Palette"), function() /*=>*/ {
			var dia = dialogCall(o_dialog_file_name, mouse_mx + ui(8), mouse_my + ui(8));
			dia.onModify = function(txt) /*=>*/ {
				var file = file_text_open_write(txt + ".hex");
				for(var i = 0; i < array_length(palette); i++)
					file_text_write_string(file,  $"{color_get_hex(palette[i])}\n");
				file_text_close(file);
				
				__refreshPalette();
			};
			
			dia.path = menu_add_target == ""? DIRECTORY + "Palettes/" : menu_add_target;
		}),
		
		menuItem(__txt("Lospec"), function() /*=>*/ {
			fileNameCall("", function(txt) /*=>*/ { addPalette_LoSpec(txt, menu_add_target); }).setName("Palette")
		}),
	];
#endregion

#region presets
	hovering_name    = "";
	preset_show_name = true;
	preset_expands   = {};
	
	pal_padding = ui(9);
	sp_preset_w = ui(240) - pal_padding * 2 - ui(8);
	palCollAll  = 0;
	projectPal  = {
		name    : "Project",
		path    : "Project", 
		content : DEF_PALETTE,
	};
	
	function drawPaletteFile(p, _x, _y, _m) {
		var _hov = sp_presets.hover;
		var _foc = sp_presets.active && interactable;
		
		var ww = sp_presets.surface_w - _x;
		var pd = ui(2);
		var nh = preset_show_name? ui(20) : pd;
		
		var gs = ui(20);
		var hh = 0;
		
		var pw  = ww - pd * 2;
		var ph  = nh + gs + pd;
		var col = max(1, floor(pw / gs)), row;
		
		var _exp, _height, pre_amo, _palRes;
		
		var lbh = ui(20);
		var sch = search_string != "";
		
		var bs = lbh - ui(4);
		
		if(p.content == undefined)
			p.content = loadPalette(p.path);
		
		var _name = p.name;
		var _path = p.path;
		var _palt = p.content;
		
		if(sch && string_pos(search_string, string_lower(_name)) == 0) return 0;
		if(!is_array(_palt)) return 0;
		
		pre_amo  = array_length(_palt);
		row      = ceil(pre_amo / col);
		_exp     = preset_expands[$ _path] || row <= 1;
		_height  = _exp? nh + row * gs + pd : ph;
		
		var isHover = _hov && point_in_rectangle(_m[0], _m[1], _x, _y, _x + ww, _y + _height);
		var select  = isHover;
		draw_sprite_stretched(THEME.ui_panel_bg, 3, _x, _y, ww, _height);
		
		if(isHover) {
			draw_sprite_stretched_ext(THEME.node_bg, 1, _x, _y, ww, _height, COLORS._main_accent, 1);
			sp_presets.hover_content = true;
		}
		
		if(preset_show_name) {
			draw_sprite_ui(THEME.arrow, _exp * 3, _x + ui(8), _y + nh / 2, .75, .75, 0, COLORS._main_text_sub);
			draw_set_text(f_p4, fa_left, fa_top, COLORS._main_text);
			draw_text_add(_x + ui(16), _y + ui(2), _name);
			
			var bx = _x + ww - ui(2) - bs;
			var by = _y + ui(2);
			
			if(p != projectPal) {
				var bt = __txt("Favorite");
				var bc = p.fav? CDEF.yellow : COLORS._main_icon;
				var b  = buttonInstant_Pad(noone, bx, by, bs, bs, _m, _hov, _foc, bt, THEME.favorite, p.fav, bc, .85);
				if(b) { select = false; isHover = false; };
				if(b == 2) __fav = p;
			}
			bx -= bs + 1;
			
			var b  = buttonInstant_Pad(noone, bx, by, bs, bs, _m, _hov, _foc, "Set Palette", THEME.node_goto_16,,, .85);
			if(b) { select = false; isHover = false; };
			if(b == 2) {
				setPalette(array_clone(_palt)); 
				onApply(palette);
			}
		}
		
		var _hoverColor = noone;
		if(_exp) {
			_palRes     = drawPaletteGrid(_palt, _x + pd, _y + nh, pw, gs, { mx : _m[0], my : _m[1] });
			_hoverColor = _palRes.hoverIndex > noone? _palRes.hoverColor : noone;
		} else drawPalette(_palt, _x + pd, _y + nh, pw, gs);
		
		if(_hoverColor != noone) {
			var _box = _palRes.hoverBBOX;
			draw_sprite_stretched_ext(THEME.box_r2, 1, _box[0], _box[1], _box[2], _box[3], c_white);
			
			if(mouse_lpress(_foc))
				selector.setColor(_hoverColor);
			
			select = false;
		}
		
		if(select && mouse_lpress(_foc)) {
			preset_expands[$ _path] = !_exp;
			click_block = true;
			onApply(palette);
		}
		
		if(isHover && mouse_rpress(_foc)) {
			menuCall("palette_window_preset_menu", [
				menuItem(__txt("Set Palette"), function(p) /*=>*/ { setPalette(array_clone(p)); onApply(palette); }).setParam(_palt),
				menuItem(__txtx("palette_editor_set_default", "Set as default"), function(p) /*=>*/ { PROJECT.setPalette(array_clone(p)); }).setParam(_palt),
				menuItem(__txtx("palette_editor_delete", "Delete palette"),      function(p) /*=>*/ { file_delete(p); __refreshPalette(); }).setParam(_path),
			]);
		}
		
		return _height + ui(4);
	}
	
	function drawPaletteDirectory(_dir, _x, _y, _m) {
		var _hov = sp_presets.hover;
		var _foc = sp_presets.active && interactable;
		var  ww  = sp_presets.surface_w - _x;
		
		var hh = 0;
		
		var lbh = ui(20);
		var sch = search_string != "";
		
		var bs = lbh - ui(4);
		
		for( var i = 0, n = array_length(_dir.subDir); i < n; i++ ) {
			var _sub  = _dir.subDir[i];
			var _open = sch || _sub.open;
			if(_sub.name == "Mixer") continue;
			
			var _favFol = _sub.path == "Favorites";
			var _hovSec = _hov && point_in_rectangle(_m[0], _m[1], _x, _y, _x + ww, _y + lbh);
			draw_sprite_stretched(THEME.ui_panel_bg, 3, _x, _y, ww, lbh);
			
			#region buttons
				var bx = _x + ww - ui(2) - bs;
				var by = _y + ui(2);
				
				if(!_favFol) {
					var bt = __txt("Add preset to folder...");
					var bc = [COLORS._main_icon, COLORS._main_value_positive];
					var b  = buttonInstant_Pad(noone, bx, by, bs, bs, _m, _hov, _foc, bt, THEME.add, 0, bc, .85);
					if(b) { _hovSec = false; isHover = false; };
					if(b == 2) {
						menu_add_target = _sub.path;
						menuCall("", menu_add);
					}
					bx -= bs + 1;
				}
			#endregion
			
			if(!sch && _hovSec) {
				draw_sprite_stretched_ext(THEME.node_bg, 1, _x, _y, ww, lbh, COLORS._main_icon, 1);
				if(DOUBLE_CLICK && _foc) {
					palCollAll = _open? 1 : -1;
					
				} else if(mouse_lpress(_foc)) {
					_open = !_open;
					_sub.open = _open;
				}
			}
			
			draw_sprite_ui_uniform(THEME.arrow, _open * 3, _x + ui(12), _y + lbh/2, .8, COLORS._main_icon);
			var _tx = _x + ui(24);
			if(_favFol) {
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
			var p  = _dir.content[i];
			var _h = drawPaletteFile(p, _x, _y, _m);
			
			_y += _h;
			hh += _h;
		}
		
		return hh;
	}
	
	sp_presets  = new scrollPane(sp_preset_w, dialog_h - ui(48 + 8 + 40) - pal_padding, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		__fav = undefined;
		var hh = 0;
		
		var _h = drawPaletteFile(projectPal, 0, _y, _m);
		_y += _h; hh += _h;
		
		var _h = drawPaletteDirectory(PALETTES_FOLDER, 0, _y, _m);
		_y += _h; hh += _h;
		
		if(__fav) __togglePaletteFav(__fav);
		
		if(palCollAll ==  1) PALETTES_FOLDER.openAll();
		if(palCollAll == -1) PALETTES_FOLDER.closeAll();
		palCollAll = 0;
		
		return hh;
	});
	
	//////////////////////// SEARCH ////////////////////////
	
	search_string = "";
	tb_search = textBox_Text(function(t) /*=>*/ { search_string = string_lower(t); } )
	               .setFont(f_p2).setHide(1).setEmpty(false).setPadding(ui(24)).setAutoUpdate().setClearable();
	
	////////////////////////  SORT  ////////////////////////
	
	function sortPalettePreset(fn, _sub = false) {
		array_remove(PALETTES_FOLDER.subDir, PALETTES_FAV_DIR);
		PALETTES_FAV_DIR.sort(fn);
		PALETTES_FOLDER.sort(fn, _sub, true);
		array_insert(PALETTES_FOLDER.subDir, 0, PALETTES_FAV_DIR);
	}
	
	sortPreset_name_a = function() /*=>*/ { sortPalettePreset(function(p0, p1) /*=>*/ {return string_compare(p0.name, p1.name)}, true); }
	sortPreset_name_d = function() /*=>*/ { sortPalettePreset(function(p0, p1) /*=>*/ {return string_compare(p1.name, p0.name)}, true); }
	
	sortPreset_size_a = function() /*=>*/ { sortPalettePreset(function(p0, p1) /*=>*/ {return array_length(p0.content) - array_length(p1.content)}); }
	sortPreset_size_d = function() /*=>*/ { sortPalettePreset(function(p0, p1) /*=>*/ {return array_length(p1.content) - array_length(p0.content)}); }
	
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

#region functions
	function refreshPaletteObject() {
		if(palette == 0) return;
		
		paletteObject = array_verify_ext(paletteObject, array_length(palette), function() /*=>*/ {return new __PaletteColor()});
		for( var i = 0, n = array_length(palette); i < n; i++ ) paletteObject[i].color = palette[i];
	}
	
	function refreshPalette() {
		palette = [];
		for( var i = 0, n = array_length(paletteObject); i < n; i++ )
			palette[i] = paletteObject[i].color;
		
		onApply(palette);
	}
	
	function sortPalette(sortFunc) {
		if(index_selecting[1] < 2) { array_sort(paletteObject, sortFunc); refreshPalette(); return; }
			
		var _arr = array_create(index_selecting[1]);
		for(var i = 0; i < index_selecting[1]; i++)
			_arr[i] = paletteObject[index_selecting[0] + i];
		array_sort(_arr, sortFunc);
		
		for(var i = 0; i < index_selecting[1]; i++)
			paletteObject[index_selecting[0] + i] = _arr[i];
			
		refreshPalette();
	}
	
	function setDefault(pal) { setPalette(pal); previous_palette = array_clone(pal); return self; }
	
	function setPalette(pal, _reset_select = true) {
		palette = pal;	
		refreshPaletteObject();
		
		if(!_reset_select) return;
		index_selecting = [ 0, 0 ];
		if(!array_empty(palette)) selector.setColor(palette[0]);
		mixer = noone;
	}
	
	function setPaletteSelecting(pal) {
		if(index_selecting[1] == 0) {
			setPalette(pal, false);
			return;
		}
		
		array_delete(palette, index_selecting[0], index_selecting[1]);
		for( var i = 0, n = array_length(pal); i < n; i++ )
			array_insert(palette, index_selecting[0] + i, pal[i]);
		
		index_selecting[1] = array_length(pal);
		refreshPaletteObject();
		
		if(onApply != noone) onApply(palette);
	} 
	
	function checkMouse() {}
	
	menu_palette_sort = [
		new MenuItem_Sort(__txtx("palette_editor_sort_brightness", "Brightness"), 
			[ function() /*=>*/ {return sortPalette(function(a,b) /*=>*/ {return __sortBright(a.color, b.color)})}, function() /*=>*/ {return sortPalette(function(a,b) /*=>*/ {return __sortDark(a.color, b.color)})} ]),
		-1,
		new MenuItem_Sort(__txtx("palette_editor_sort_hue", "Hue"),           
			[ function() /*=>*/ {return sortPalette(function(a,b) /*=>*/ {return __sortHue(a.color, b.color)})}, function() /*=>*/ {return sortPalette(function(a,b) /*=>*/ {return __sortHue(b.color, a.color)})} ] ),
		new MenuItem_Sort(__txtx("palette_editor_sort_sat", "Saturation"),    
			[ function() /*=>*/ {return sortPalette(function(a,b) /*=>*/ {return __sortSat(a.color, b.color)})}, function() /*=>*/ {return sortPalette(function(a,b) /*=>*/ {return __sortSat(b.color, a.color)})} ] ),
		new MenuItem_Sort(__txtx("palette_editor_sort_val", "Value"),         
			[ function() /*=>*/ {return sortPalette(function(a,b) /*=>*/ {return __sortVal(a.color, b.color)})}, function() /*=>*/ {return sortPalette(function(a,b) /*=>*/ {return __sortVal(b.color, a.color)})} ] ),
	];
#endregion