/// @description init
event_inherited();

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
		
		for( var i = 0, n = array_length(_dir.subDir); i < n; i++ ) {
			var _sub  = _dir.subDir[i];
			var _open = sch || (_sub[$ "expanded"] ?? true);
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, _x, _y, ww, lbh);
			if(!sch && _hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + ww, _y + lbh)) {
				draw_sprite_stretched_ext(THEME.node_bg, 1, _x, _y, ww, lbh, COLORS._main_icon, 1);
				if(mouse_lpress(_focus)) {
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
			
			if(_hover && isHover) {
				if(mouse_press(mb_left, _focus)) {
					gradient.keys = [];
					for( var i = 0, n = array_length(_grad.keys); i < n; i++ ) {
						var k = _grad.keys[i].clone();
						gradient.keys[i] = k;
						
						if(is_real(k.value)) k.value = cola(k.value);
					}
					
					onApply(gradient);
				}
				
				if(mouse_press(mb_right, _focus)) {
					menuCall("gradient_window_preset_menu", [ 
						menuItem(__txtx("gradient_editor_delete", "Delete gradient"), 
							function(p) /*=>*/ { file_delete(p); __initGradient(); }).setParam(g.path)
					]);
				}
			}
			
			_y += hg + ui(4);
			hh += hg + ui(4);
		}
		
		return hh;
	} 
	
	sp_presets = new scrollPane(sp_preset_w, dialog_h - ui(48 + 8) - pal_padding, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var hh = drawGradientDirectory(GRADIENTS_FOLDER, 0, _y, _m);
		return hh;
	});
	
	//////////////////////// SEARCH ////////////////////////
	
	gradient_search_string = "";
	tb_preset_search       = textBox_Text(function(t) /*=>*/ { gradient_search_string = string_lower(t) } ).setFont(f_p2).setHide(1)
									.setEmpty(false).setPadding(ui(24)).setAutoUpdate();
									
#endregion

#region palette
	palette_selecting = undefined;
	preset_expands    = {};
	preset_show_name  = true;
	
	sp_palette_w    = ui(240) - pal_padding * 2 - ui(8);
	sp_palette_size = ui(20);
	click_block     = true;
	
	palette_spread  = undefined;
	palette_spread_index = 0;
	palette_spread_end   = 0;
	
	function drawPaletteDirectory(_dir, _x, _y, _m) {
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
		
		for( var i = 0, n = array_length(_dir.subDir); i < n; i++ ) {
			var _sub  = _dir.subDir[i];
			var _open = sch || (_sub[$ "expanded"] ?? true);
			if(_sub.name == "Mixer") continue;
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, _x, _y, ww, lbh);
			if(!sch && _hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + ww, _y + lbh)) {
				draw_sprite_stretched_ext(THEME.node_bg, 1, _x, _y, ww, lbh, COLORS._main_icon, 1);
				if(mouse_lpress(_focus)) {
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
		
		var _height, pre_amo, _palRes;
		var col = max(1, floor(_ww / _gs)), row, _exp;
		
		for( var i = 0, n = array_length(_dir.content); i < n; i++ ) {
			var p = _dir.content[i];
			if(p.content == undefined)
				p.content = loadPalette(p.path);
			
			var _name = p.name;
			var _path = p.path;
			var _palt = p.content;
			
			if(sch && string_pos(palette_search_string, string_lower(_name)) == 0) continue;
			if(!is_array(_palt)) continue;
			
			pre_amo  = array_length(_palt);
			row      = ceil(pre_amo / col);
			_exp     = preset_expands[$ _path] || row <= 1;
			_height  = _exp? nh + row * _gs + pd : _bh;
			
			var isHover = _hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + ww, _y + _height);
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, _x, _y, ww, _height);
			if(isHover) {
				sp_palettes.hover_content = true;
				draw_sprite_stretched_ext(THEME.node_bg, 1, _x, _y, ww, _height, COLORS._main_accent, 1);
			}
			
			if(preset_show_name) {
				var cc = _palt == palette_selecting? COLORS._main_accent : COLORS._main_text_sub;
				draw_sprite_ui(THEME.arrow, _exp * 3, _x + ui(8), _y + nh / 2, .75, .75, 0, COLORS._main_text_sub);
				draw_set_text(f_p3, fa_left, fa_top, cc);
				draw_text_add(_x + ui(16), _y + ui(2), _name);
				
				if(i == -1) { draw_set_color(cc); draw_circle_prec(_x + ww - ui(10), _y + ui(10), ui(4), false); }
			}
			
			var _hoverColor = noone;
			var _hoverIndex = noone;
			
			if(_exp) {
				_palRes = drawPaletteGrid(_palt, _x + pd, _y + nh, _ww, _gs, { color : selector.current_color, mx : _m[0], my : _m[1] });
				_hoverColor = _palRes.hoverIndex > noone? _palRes.hoverColor : noone;
				_hoverIndex = _palRes.hoverIndex;
			} else
				drawPalette(_palt, _x + pd, _y + nh, _ww, _gs);
			
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
							menuItem(__txtx("palette_mix_color", "Mix Color"), function(c) /*=>*/ { selector.setMixColor(c); }).setParam(_hoverColor),
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
			
			_y += _height + ui(4);
			hh += _height + ui(4);
		}
		
		return hh;
	}
	
	sp_palettes = new scrollPane(sp_palette_w, dialog_h - ui(48 + 8) - pal_padding, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var hh = drawPaletteDirectory(PALETTES_FOLDER, 0, _y, _m);
		
		if(mouse_release(mb_left)) {
			click_block    = false;
			palette_spread = undefined;
		}
		
		return hh;
	});
	
	//////////////////////// SEARCH ////////////////////////
	
	palette_search_string = "";
	tb_palette_search = textBox_Text(function(t) /*=>*/ { palette_search_string = string_lower(t) } )
		.setFont(f_p2).setHide(1).setEmpty(false).setPadding(ui(24)).setAutoUpdate();
	
	////////////////////////  SORT  ////////////////////////
	
	sortPreset_name_a = function() /*=>*/ { array_sort(paletePresets, function(p0, p1) /*=>*/ {return string_compare(p0.name, p1.name)}); }
	sortPreset_name_d = function() /*=>*/ { array_sort(paletePresets, function(p0, p1) /*=>*/ {return string_compare(p1.name, p0.name)}); }
	
	sortPreset_size_a = function() /*=>*/ { array_sort(paletePresets, function(p0, p1) /*=>*/ { return array_length(p0.palette) - array_length(p1.palette); }); }
	sortPreset_size_d = function() /*=>*/ { array_sort(paletePresets, function(p0, p1) /*=>*/ { return array_length(p1.palette) - array_length(p0.palette); }); }
	
	sortPreset_hue_a  = function() /*=>*/ { array_sort(paletePresets, function(p0, p1) /*=>*/ {return palette_compare_hue_var(p0.palette, p1.palette)}); }
	sortPreset_hue_d  = function() /*=>*/ { array_sort(paletePresets, function(p0, p1) /*=>*/ {return palette_compare_hue_var(p1.palette, p0.palette)}); }
	
	sortPreset_sat_a  = function() /*=>*/ { array_sort(paletePresets, function(p0, p1) /*=>*/ {return palette_compare_sat(p0.palette, p1.palette)}); }
	sortPreset_sat_d  = function() /*=>*/ { array_sort(paletePresets, function(p0, p1) /*=>*/ {return palette_compare_sat(p1.palette, p0.palette)}); }
	
	sortPreset_val_a  = function() /*=>*/ { array_sort(paletePresets, function(p0, p1) /*=>*/ {return palette_compare_val(p0.palette, p1.palette)}); }
	sortPreset_val_d  = function() /*=>*/ { array_sort(paletePresets, function(p0, p1) /*=>*/ {return palette_compare_val(p1.palette, p0.palette)}); }
	
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