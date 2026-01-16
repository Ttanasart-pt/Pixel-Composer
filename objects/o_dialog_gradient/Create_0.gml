/// @description init
event_inherited();
PALETTES_FOLDER.forEach(function(f)  /*=>*/ { if(f.content == undefined) f.content = loadPalette(f.path); }); // Load all presets
GRADIENTS_FOLDER.forEach(function(f) /*=>*/ { if(f.content == undefined) f.content = loadGradient(f.path); }); // Load all presets

#region data
	dialog_w = ui(1068);
	dialog_h = ui(468);
	title_height = 52;
	
	name = __txtx("gradient_editor_title", "Gradient editor");
	gradient      = noone;
	interactable  = true;
	drop_target   = noone;
	
	key_selecting = noone;
	key_dragging  = noone;
	key_deleting  = false;
	key_drag_dead = true;
	key_drag_sx   = 0;
	key_drag_sy   = 0;
	key_drag_mx   = 0;
	key_drag_my   = 0;
	
	destroy_on_click_out = true;
	
	sl_position = slider(0, 100, 0.1, function(val) /*=>*/ { if(!interactable || key_selecting == noone) return; setKeyPosition(key_selecting, val / 100); }, 
		function() /*=>*/ {return removeKeyOverlap(key_selecting)}).setLabel(__txt("Position"));
	
	setColor = function(color) {
		if(key_selecting == noone) return;
		key_selecting.value = int64(color);
		
		onApply(gradient);
	}
	
	function setGradient(grad) { 
		gradient = grad;
		if(array_empty(grad.keys)) return;
		
		key_selecting = grad.keys[0];
		selector.setColor(key_selecting.value, false);
	}
	
	selector = new colorSelector(setColor);
	selector.dropper_close = false;
	
	previous_gradient = noone;
	
	function setDefault(grad) {
		setGradient(grad);
		previous_gradient = grad.clone();
		return self;
	}
	
	b_cancel = button(function() /*=>*/ { onApply(previous_gradient); instance_destroy(); })
		.setIcon(THEME.undo, 0, COLORS._main_icon)
		.setTooltip(__txtx("dialog_revert_and_exit", "Revert and exit"));
	
	b_apply = button(function() /*=>*/ { onApply(gradient); instance_destroy(); })
		.setIcon(THEME.accept, 0, COLORS._main_icon_dark);
	
	sb_blending = new scrollBox([
		__txtx("gradient_editor_blend_hard",  "Solid"),
		__txtx("gradient_editor_blend_RGB",   "RGB"),  
		__txtx("gradient_editor_blend_HSV",   "HSV"),  
		__txtx("gradient_editor_blend_OKLAB", "OKLAB"),
		
	], function(i) /*=>*/ {
		switch(i) {
			case 0 :  gradient.type = 1; break;
			case 1 :  gradient.type = 0; break;
			case 2 :  gradient.type = 2; break;
			case 3 :  gradient.type = 3; break;
		}
		onApply(gradient);
		
	}).setFont(f_p2);
	
	function setKeyPosition(key, position) {
		key.time = position;
		
		array_remove(gradient.keys, key);
		gradient.add(key, false);
		
		onApply(gradient);
	}
	
	function removeKeyOverlap(key) {
		var keys = gradient.keys;
		for(var i = 0; i < array_length(keys); i++) {
			var _key = keys[i];
			if(_key == key || _key.time != key.time) 
				continue;
			
			_key.value = key.value;
			array_remove(keys, key);
		}
		
		onApply(gradient);
	}
#endregion

#region preset
	hovering_name = "";
	pal_padding   = ui(9);
	sp_preset_w   = ui(240) - pal_padding * 2 - ui(8);
	graCollAll    = 0;
	
	function drawGradientDirectory(_dir, _x, _y, _m) {
		var _hover = sp_presets.hover;
		var _focus = sp_presets.active && interactable;
		
		var ww  = sp_presets.surface_w - _x;
		var gh  = ui(16);
		var nh  = ui(20);
		var pd  = ui(2);
		var hg  = nh + gh + pd;
		var hh  = 0;
		
		var lbh = ui(20);
		var sch = gradient_search_string != "";
		
		var bs  = lbh - ui(4);
		var fav = undefined;
		var app = undefined;
		
		for( var i = 0, n = array_length(_dir.subDir); i < n; i++ ) {
			var _sub  = _dir.subDir[i];
			var _open = sch || _sub.open;
			
			var _favFol = _sub.path == "Favorites";
			var _hovSec = _hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + ww, _y + lbh);
			draw_sprite_stretched(THEME.ui_panel_bg, 3, _x, _y, ww, lbh);
			
			#region buttons
				var bx = _x + ww - ui(2) - bs;
				var by = _y + ui(2);
				
				if(!_favFol) {
					var bt = __txt("Add preset to folder...");
					var bc = [COLORS._main_icon, COLORS._main_value_positive];
					var b  = buttonInstant_Pad(noone, bx, by, bs, bs, _m, _hover, _focus, bt, THEME.add, 0, bc, .85);
					if(b) { _hovSec = false; isHover = false; };
					if(b == 2) {
						var dia = dialogCall(o_dialog_file_name, mouse_mx + ui(8), mouse_my + ui(8));
						dia.onModify = function (txt) {
							var gradStr = "";
							
							for(var i = 0; i < array_length(gradient.keys); i++) {
								var gr = gradient.keys[i];
								gradStr += $"{gr.value},{gr.time}\n";
							}
							
							file_text_write_all(txt + ".txt", gradStr);
							__refreshGradient();
						};
						dia.path = _sub.path;
					}
				}
				
				bx -= bs + 1;
			#endregion
			
			if(!sch && _hovSec) {
				draw_sprite_stretched_ext(THEME.node_bg, 1, _x, _y, ww, lbh, COLORS._main_icon, 1);
				if(DOUBLE_CLICK && _focus) {
					graCollAll = _open? 1 : -1;
					
				} else if(mouse_lpress(_focus)) {
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
			var _sh  = drawGradientDirectory(_sub, _x + ui(8), _y, _m);
			
			_y += _sh;
			hh += _sh;
		}
		
		for( var i = 0, n = array_length(_dir.content); i < n; i++ ) {
			var g = _dir.content[i];
			if(g.content == undefined)
				g.content = loadGradient(g.path);
			
			var _name = g.name;
			var _grad = g.content;
			
			if(sch && string_pos(gradient_search_string, string_lower(_name)) == 0) continue;
			if(!is(_grad, gradientObject)) continue;
			
			var isHover = point_in_rectangle(_m[0], _m[1], _x, _y, _x + ww, _y + hg);
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, _x, _y, ww, hg);
			if(_hover && isHover) {
				sp_presets.hover_content = true;
				draw_sprite_stretched_ext(THEME.node_bg, 1, _x, _y, ww, hg, COLORS._main_accent, 1);
			}
				
			draw_set_text(f_p4, fa_left, fa_top, COLORS._main_text);
			draw_text_add(_x + pd + ui(4), _y + ui(2), _name);
			_grad.draw(_x + pd, _y + nh, ww - pd * 2, gh);
			
			var bx = _x + ww - ui(2) - bs;
			var by = _y + ui(2);
			
			var bt = __txt("Favorite");
			var bc = g.fav? CDEF.yellow : COLORS._main_icon;
			var b  = buttonInstant_Pad(noone, bx, by, bs, bs, _m, _hover, _focus, bt, THEME.favorite, g.fav, bc, .85);
			if(b) isHover = false;
			if(b == 2) fav = g;
			bx -= bs + 1;
			
			if(_hover && isHover) {
				if(mouse_press(mb_left, _focus))
					app = _grad;
				
				if(mouse_press(mb_right, _focus)) {
					menuCall("gradient_window_preset_menu", [ 
						menuItem(__txtx("gradient_editor_delete", "Delete gradient"), 
							function(p) /*=>*/ { file_delete(p); __refreshGradient(); }).setParam(g.path)
					]);
				}
			}
			
			_y += hg + ui(4);
			hh += hg + ui(4);
		}
		
		if(app != undefined) {
			gradient.keys = [];
			for( var i = 0, n = array_length(app.keys); i < n; i++ ) {
				var k = app.keys[i].clone();
				gradient.keys[i] = k;
				
				if(is_real(k.value)) k.value = cola(k.value);
			}
			
			onApply(gradient);
		}
		
		if(fav) __toggleGradientFav(fav);
		
		return hh;
	} 
	
	sp_presets = new scrollPane(sp_preset_w, dialog_h - ui(48 + 8) - pal_padding, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var hh = drawGradientDirectory(GRADIENTS_FOLDER, 0, _y, _m);
		
		if(graCollAll ==  1) GRADIENTS_FOLDER.openAll();
		if(graCollAll == -1) GRADIENTS_FOLDER.closeAll();
		graCollAll = 0;
		
		return hh;
	});
	
	//////////////////////// SEARCH ////////////////////////
	
	gradient_search_string = "";
	tb_preset_search       = textBox_Text(function(t) /*=>*/ { gradient_search_string = string_lower(t) } ).setFont(f_p2).setHide(1)
		.setEmpty(false).setPadding(ui(24)).setAutoUpdate().setClearable();
				
	////////////////////////  SORT  ////////////////////////
	
	function sortGradientPreset(fn, _sub = false) {
		array_remove(GRADIENTS_FOLDER.subDir, GRADIENTS_FAV_DIR);
		GRADIENTS_FAV_DIR.sort(fn);
		GRADIENTS_FOLDER.sort(fn, _sub, true);
		array_insert(GRADIENTS_FOLDER.subDir, 0, GRADIENTS_FAV_DIR);
	}
	
	sortGradPreset_name_a = function() /*=>*/ { sortGradientPreset(function(p0, p1) /*=>*/ {return string_compare(p0.name, p1.name)}, true); }
	sortGradPreset_name_d = function() /*=>*/ { sortGradientPreset(function(p0, p1) /*=>*/ {return string_compare(p1.name, p0.name)}, true); }
	
	sortGradPreset_hue_a  = function() /*=>*/ { sortGradientPreset(function(p0, p1) /*=>*/ {return gradient_compare_hue(p0.content, p1.content)}); }
	sortGradPreset_hue_d  = function() /*=>*/ { sortGradientPreset(function(p0, p1) /*=>*/ {return gradient_compare_hue(p1.content, p0.content)}); }
	
	sortGradPreset_sat_a  = function() /*=>*/ { sortGradientPreset(function(p0, p1) /*=>*/ {return gradient_compare_sat(p0.content, p1.content)}); }
	sortGradPreset_sat_d  = function() /*=>*/ { sortGradientPreset(function(p0, p1) /*=>*/ {return gradient_compare_sat(p1.content, p0.content)}); }
	
	sortGradPreset_val_a  = function() /*=>*/ { sortGradientPreset(function(p0, p1) /*=>*/ {return gradient_compare_val(p0.content, p1.content)}); }
	sortGradPreset_val_d  = function() /*=>*/ { sortGradientPreset(function(p0, p1) /*=>*/ {return gradient_compare_val(p1.content, p0.content)}); }
	
	menu_grad_preset_sort = [
		new MenuItem_Sort(__txt("Name"), [ sortGradPreset_name_a, sortGradPreset_name_d ]),
		-1,
		new MenuItem_Sort(__txt("Hue Average"), [ sortGradPreset_hue_a,  sortGradPreset_hue_d ]),
		new MenuItem_Sort(__txt("Sat Average"), [ sortGradPreset_sat_a,  sortGradPreset_sat_d ]),
		new MenuItem_Sort(__txt("Val Average"), [ sortGradPreset_val_a,  sortGradPreset_val_d ]),
	];					
#endregion

#region palette
	palette_selecting = undefined;
	preset_expands    = {};
	preset_show_name  = true;
	
	sp_palette_w    = ui(240) - pal_padding * 2 - ui(8);
	sp_palette_size = ui(20);
	click_block     = true;
	palCollAll      = 0;
	projectPal      = {
		name    : "Project",
		path    : "Project", 
		content : DEF_PALETTE,
	};
	
	palette_spread  = undefined;
	palette_spread_index = 0;
	palette_spread_end   = 0;
	
	function drawPaletteFile(p, _x, _y, _m) {
		var _hover = sp_palettes.hover;
		var _focus = sp_palettes.active && interactable;
		
		var ww  = sp_palettes.surface_w - _x;
		var _gs = sp_palette_size;
		
		var hh  = 0;
		var pd  = ui(2);
		var nh  = preset_show_name? ui(20) : pd;
		var _ww = ww - pd * 2;
		var _bh = nh + _gs + pd;
		
		var lbh = ui(20);
		var sch = palette_search_string != "";
		
		var bs = lbh - ui(4);
		
		if(p.content == undefined)
			p.content = loadPalette(p.path);
		
		var _name = p.name;
		var _path = p.path;
		var _palt = p.content;
		
		if(sch && string_pos(palette_search_string, string_lower(_name)) == 0) return 0;
		if(!is_array(_palt)) return 0;
		
		var col = max(1, floor(_ww / _gs));
		var pre_amo  = array_length(_palt);
		var row      = ceil(pre_amo / col);
		var _exp     = preset_expands[$ _path] || row <= 1;
		var _height  = _exp? nh + row * _gs + pd : _bh;
		var _palRes;
		
		var isHover = _hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + ww, _y + _height);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 3, _x, _y, ww, _height);
		if(isHover) {
			sp_palettes.hover_content = true;
			draw_sprite_stretched_ext(THEME.node_bg, 1, _x, _y, ww, _height, COLORS._main_accent, 1);
		}
		
		if(preset_show_name) {
			var cc = _palt == palette_selecting? COLORS._main_accent : COLORS._main_text;
			draw_sprite_ui(THEME.arrow, _exp * 3, _x + ui(8), _y + nh / 2, .75, .75, 0, COLORS._main_text_sub);
			draw_set_text(f_p4, fa_left, fa_top, cc);
			draw_text_add(_x + ui(16), _y + ui(2), _name);
			
			var bx = _x + ww - ui(2) - bs;
			var by = _y + ui(2);
			
			if(p != projectPal) {
				var bt = __txt("Favorite");
				var bc = p.fav? CDEF.yellow : COLORS._main_icon;
				var b  = buttonInstant_Pad(noone, bx, by, bs, bs, _m, _hover, _focus, bt, THEME.favorite, p.fav, bc, .85);
				if(b) isHover = false;
				if(b == 2) __fav = p;
			}
			
			bx -= bs + 1;
		}
		
		var _hoverColor = noone;
		var _hoverIndex = noone;
		
		if(_exp) {
			var _sel = palette_spread == _path? undefined : selector.current_color;
			
			_palRes = drawPaletteGrid(_palt, _x + pd, _y + nh, _ww, _gs, { color : _sel, mx : _m[0], my : _m[1] });
			_hoverColor = _palRes.hoverIndex > noone? _palRes.hoverColor : noone;
			_hoverIndex = _palRes.hoverIndex;
			
			if(palette_spread == _path) {
				var _sgn = sign(_hoverIndex - palette_spread_index);
				var _amo = abs(_hoverIndex - palette_spread_index) + 1;
				var _ind = palette_spread_index;
				
				var gd_c = _palRes.gridColumn;
				var gd_r = _palRes.gridRow;
				var gd_w = _palRes.gridWidth;
				var gd_h = _palRes.gridHeight;
				
				draw_set_color(c_white);
				repeat(_amo) {
					var _c  = _ind % gd_c;
					var _r  = floor(_ind / gd_c);
					var _x0 = _x + pd + _c * gd_w;
					var _y0 = _y + nh + _r * gd_h;
					
					if(_ind == palette_spread_index || _ind == _hoverIndex)
						draw_sprite_stretched_ext(THEME.palette_selecting, 0, _x0 - 5, _y0 - 5, gd_w + 5 * 2, gd_h + 5 * 2);
					else 
						draw_line_width(_x0, _y0 + gd_h / 2, _x0 + gd_w, _y0 + gd_h / 2, ui(3));
					_ind += _sgn;
				}
			}
			
		} else drawPalette(_palt, _x + pd, _y + nh, _ww, _gs);
		
		if(_hoverColor != noone) {
			var _box = _palRes.hoverBBOX;
			draw_sprite_stretched_ext(THEME.box_r2, 1, _box[0], _box[1], _box[2], _box[3], c_white);
		}
		
		if(palette_spread == _path && _hoverIndex != noone) {
			if(palette_spread_end != _hoverIndex) {
				var _sgn = sign(_hoverIndex - palette_spread_index);
				var _amo = abs(_hoverIndex - palette_spread_index) + 1;
				var _ind = palette_spread_index;
				
				if(_amo == 1) {
					gradient = new gradientObject(_palt[palette_spread_index]);
					
				} else {
					gradient = new gradientObject();
					
					var _stp = 1 / (_amo - 1);
					var _prg = 0, j = 0;
					
					repeat(_amo) {
						var _cc = _palt[_ind];
						gradient.keys[j++] = new gradientKey(_prg, _cc);
						
						_prg += _stp;
						_ind += _sgn;
					}
				}
				
				onApply(gradient);
			}
			
			palette_spread_end = _hoverIndex;
		}
		
		if(!click_block && _focus) {
			if(mouse_click(mb_left)) {
				if(key_mod_press(CTRL)) {
					if(palette_spread == undefined && _hoverIndex != noone) {
						palette_spread       = _path;
						palette_spread_index = _hoverIndex;
					}
					
				} else if(_hoverColor != noone) {
					var c = _hoverColor;
					if(is_real(c)) c = cola(c);
					
					selector.setColor(c);
					selector.setHSV();
					
				} else if(isHover) {
					preset_expands[$ _path] = !_exp;
					palette_selecting       = _palt;
					click_block             = true;
				}
			}
			
			if(mouse_click(mb_right)) {
				if(_hoverColor != noone) {
					menuCall("palette_window_preset_menu", [
						menuItem(__txtx("gradient_set_single", "Set Single"), function(c) /*=>*/ { gradient = new gradientObject(c); }).setParam(_hoverColor),
						menuItem(__txtx("palette_mix_color", "Mix Color"),    function(c) /*=>*/ { selector.setMixColor(c); }).setParam(_hoverColor),
					]);
					
				} else if(isHover) {
					menuCall("palette_window_preset_menu", [
						menuItem(__txtx("gradient_set_palette", "Convert to Gradient"), function(_palt) { 
							if(array_length(_palt) < 2) return;
							
							gradient.keys = [];
							for( var i = 0, n = array_length(_palt); i < n; i++ )
								gradient.keys[i] = new gradientKey(i / (n - 1), cola(_palt[i]));
								
						}).setParam(_palt),
					]);
				}
			}
		}
		
		return _height + ui(4);
	}
	
	function drawPaletteDirectory(_dir, _x, _y, _m) {
		var _hover = sp_palettes.hover;
		var _focus = sp_palettes.active && interactable;
		
		var ww  = sp_palettes.surface_w - _x;
		var hh  = 0;
		
		var lbh = ui(20);
		var sch = palette_search_string != "";
		var bs  = lbh - ui(4);
		
		for( var i = 0, n = array_length(_dir.subDir); i < n; i++ ) {
			var _sub  = _dir.subDir[i];
			var _open = sch || _sub.open;
			if(_sub.name == "Mixer") continue;
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, _x, _y, ww, lbh);
			if(!sch && _hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + ww, _y + lbh)) {
				draw_sprite_stretched_ext(THEME.node_bg, 1, _x, _y, ww, lbh, COLORS._main_icon, 1);
				if(DOUBLE_CLICK && _focus) {
					palCollAll = _open? 1 : -1;
					
				} else if(mouse_lpress(_focus)) {
					_open = !_open;
					_sub.open = _open;
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
			var  p = _dir.content[i];
			var _h = drawPaletteFile(p, _x, _y, _m);
			
			_y += _h;
			hh += _h;
		}
		
		return hh;
	}
	
	sp_palettes = new scrollPane(sp_palette_w, dialog_h - ui(48 + 8) - pal_padding, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var hh = 0;
		__fav  = undefined;
		
		var _h = drawPaletteFile(projectPal, 0, _y, _m);
		_y += _h; hh += hh;
		
		var _h = drawPaletteDirectory(PALETTES_FOLDER, 0, _y, _m);
		_y += _h; hh += _h;
		
		if(__fav) __togglePaletteFav(__fav);
		
		if(mouse_release(mb_left)) {
			click_block    = false;
			palette_spread = undefined;
		}
		
		if(palCollAll ==  1) PALETTES_FOLDER.openAll();
		if(palCollAll == -1) PALETTES_FOLDER.closeAll();
		palCollAll = 0;
		
		return hh;
	});
	
	//////////////////////// SEARCH ////////////////////////
	
	palette_search_string = "";
	tb_palette_search = textBox_Text(function(t) /*=>*/ { palette_search_string = string_lower(t) } )
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
		new MenuItem_Sort(__txt("Name"), [ sortPreset_name_a, sortPreset_name_d]),
		new MenuItem_Sort(__txt("Size"), [ sortPreset_size_a, sortPreset_size_d]),
		-1,
		new MenuItem_Sort(__txt("Hue Flex"),    [ sortPreset_hue_a,  sortPreset_hue_d ]),
		new MenuItem_Sort(__txt("Sat Average"), [ sortPreset_sat_a,  sortPreset_sat_d ]),
		new MenuItem_Sort(__txt("Val Average"), [ sortPreset_val_a,  sortPreset_val_d ]),
	];
#endregion

#region action
	function checkMouse() {}
#endregion