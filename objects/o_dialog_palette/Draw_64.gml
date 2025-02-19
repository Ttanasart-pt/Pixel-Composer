/// @description init
if !ready exit;
if palette == 0 exit;
draggable = true;

#region dropper
	selector.interactable = interactable;
	if(selector.dropper_active) { selector.drawDropper(self); exit; }
#endregion

#region base UI
	var presets_x  = dialog_x;
	var presets_w  = ui(240);
	
	var content_x = dialog_x + presets_w + ui(16);
	var content_w = dialog_w - presets_w - ui(16);
	
	var p  = DIALOG_PAD;
	var p2 = DIALOG_PAD * 2;
	
	draw_sprite_stretched(THEME.dialog, 0, presets_x - p, dialog_y - p, presets_w + p2, dialog_h + p2);
	if(sFOCUS) draw_sprite_stretched_ext(THEME.dialog, 1, presets_x - p, dialog_y - p, presets_w + p2, dialog_h + p2, COLORS._main_accent, 1);
	
	draw_sprite_stretched(THEME.dialog, 0, content_x - p, dialog_y - p, content_w + p2, dialog_h + p2);
	if(sFOCUS) draw_sprite_stretched_ext(THEME.dialog, 1, content_x - p, dialog_y - p, content_w + p2, dialog_h + p2, COLORS._main_accent, 1);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	draw_text(presets_x + ui(24), dialog_y + ui(16), __txt("Presets"));
	draw_text(content_x + (!interactable * ui(32)) + ui(24), dialog_y + ui(16), name);
	if(!interactable)
		draw_sprite_ui(THEME.lock, 0, content_x + ui(24 + 12), dialog_y + ui(16 + 12),,,, COLORS._main_icon);
#endregion

#region presets
	draw_sprite_stretched(THEME.ui_panel_bg, 1, presets_x + pal_padding, dialog_y + ui(48), ui(240) - pal_padding * 2, dialog_h - ui(48) - pal_padding);
	
	sp_presets.setFocusHover(sFOCUS, sHOVER);
	sp_presets.draw(presets_x + pal_padding + ui(4), dialog_y + ui(48) + ui(4));
	
	var bx = presets_x + presets_w - ui(44);
	var by = dialog_y + ui(12);
	var bs = ui(28);
	
	var b = buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mouse_ui, sHOVER, sFOCUS, __txt("Add preset..."), THEME.add_16);
	if(b == 2) menuCall("", menu_add, bx + bs, by + bs);
	draggable &= !b;
	bx -= ui(32);
	
	var b = buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mouse_ui, sHOVER, sFOCUS, __txt("View settings..."), THEME.sort_v);
	if(b == 2) {
		var _menu = menuCall("", menu_preset_sort, bx + bs, by + bs);
		_menu.close_on_trigger = false;
	}
	draggable &= !b;
	bx -= ui(32);
	
	var b = buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mouse_ui, sHOVER, sFOCUS, __txt("Refresh"), THEME.refresh_20);
	if(b == 2) __initPalette();
	draggable &= !b;
	bx -= ui(32);
	
	var b = buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mouse_ui, sHOVER, sFOCUS, __txtx("color_selector_open_palette", "Open palette folder..."), THEME.path_open_20);
	if(b == 2) shellOpenExplorer(DIRECTORY + "Palettes")
	draw_sprite_ui_uniform(THEME.path_open_20, 1, bx + bs / 2, by + bs / 2, 1, c_white);
	draggable &= !b;
	bx -= ui(32);
#endregion

#region palette
	#region tools
		var bx = content_x + content_w - ui(50);
		var by = dialog_y + ui(16);
		
		var _txt = index_selecting[1] < 2? __txtx("palette_editor_sort", "Sort palette...") : __txtx("palette_editor_sort_selected", "Sort selected...");
		var b = buttonInstant(THEME.button_hide_fill, bx, by, ui(28), ui(28), mouse_ui, sHOVER, interactable && sFOCUS, _txt, THEME.sort);
		if(b) {
			mouse_draggable = false;
			draggable       = false;
		}
		
		if(b == 2) {
			var _menu = menuCall("palette_window_sort_menu", menu_palette_sort, bx + ui(32), by);
			_menu.close_on_trigger = false;
		}
		bx -= ui(32);
		
		var _txt = index_selecting[1] < 2? __txtx("palette_editor_reverse", "Reverse palette") : __txtx("palette_editor_reverse_selected", "Reverse selected");
		var b = buttonInstant(THEME.button_hide_fill, bx, by, ui(28), ui(28), mouse_ui, sHOVER, interactable && sFOCUS, _txt, THEME.reverse);
		if(b) {
			mouse_draggable = false;
			draggable       = false;
		}
		
		if(b == 2) {
			if(index_selecting[1] < 2)
				paletteObject = array_reverse(paletteObject);
				
			else {
				var _arr = array_create(index_selecting[1]);
				for(var i = 0; i < index_selecting[1]; i++)
					_arr[i] = paletteObject[index_selecting[0] + i];
				_arr = array_reverse(_arr);
				
				for(var i = 0; i < index_selecting[1]; i++)
					paletteObject[index_selecting[0] + i] = _arr[i];
			}
			
			refreshPalette();
		}
		bx -= ui(32);
		
		var cc = mixer == noone? COLORS._main_icon : COLORS._main_accent;
		var b = buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mouse_ui, sHOVER, sFOCUS, __txt("Palette Mixer"), THEME.icon_canvas_24, 0, cc);
		if(b == 2) {
			if(mixer) {
				mixer = noone;
			} else {
				mixer = new Panel_Palette_Mixer(self);
				
				var _pal = index_selecting[1]? array_get_sub(palette, index_selecting[0], index_selecting[1]) : palette;
				mixer.setPalette(_pal);
			}
		}
		draggable &= !b;
		bx -= ui(32);
		
	#endregion
	
	var pl_x = content_x + ui(60);
	var pl_y = dialog_y + ui(54);
	var pl_w = content_w - ui(154);
	var hh   = ui(24);
	
	var pd   = ui(0);
	var _len = array_length(palette);
	
	var min_col = 8;
	var col  = min(_len, min_col);
	var row  = ceil(_len / col);
	if(row > 8) {
		col = 16;
		row = ceil(_len / col);
	}
	
	var ww   = pl_w / col;
	var pl_h = hh * row;
	
	dialog_h = ui(408) + pl_h;
	
	var pdd = ui(6);
	var pl_sx = pl_x - pdd;
	var pl_sy = pl_y - pdd;
	var pl_sw = pl_w + pdd * 2;
	var pl_sh = pl_h + pdd * 2;
	
	draw_sprite_stretched(THEME.textbox, 3, pl_sx, pl_sy, pl_sw, pl_sh);
	draw_sprite_stretched(THEME.textbox, 0, pl_sx, pl_sy, pl_sw, pl_sh);
	
	selection_surface = surface_verify(selection_surface, pl_sw, pl_sh);
	
	var hover = -1, hvx, hvy;
	
	var _pw = ceil(ww - pd * 2);
	var _ph = ceil(hh - pd * 2);
	
	var _spx = pl_x - pdd;
	var _spy = pl_y - pdd;
	
	var _hedge  = false;
	var _palInd = [];
	
	for(var i = 0; i < row; i++)
	for(var j = 0; j < col; j++) {
		var index = i * col + j;
		if(index >= _len) break;
		
		var _p = paletteObject[index];
		
		var _kx = pl_x + j * ww;
		var _ky = pl_y + i * hh;
		
		var _px = floor(_kx + pd) - dialog_x;
		var _py = floor(_ky + pd) - dialog_y;
		
		_p.x = _p.x == 0? _px : lerp_float(_p.x, _px, 4);
		_p.y = _p.y == 0? _py : lerp_float(_p.y, _py, 4);
		
		var _selecting = index >= index_selecting[0] && index < index_selecting[0] + index_selecting[1];
		var _pdx = dialog_x + _p.x;
		var _pdy = dialog_y + _p.y;
		
		var _ind = 0;
		
		if(row == 1) {
				 if(j == 0)                                   _ind = 2;
			else if(j == col - 1)                             _ind = 3;
			
		} else {
				 if(index == 0)     	                      _ind = 6;
			else if(i == 0 && j == col - 1)                   _ind = 7;
			else if(i == row - 2) {
			     if(j == col - 1 && _len - 1 < index + col)   _ind = 9;
			     
			} else if(i == row - 1) {
				 if(j == 0)                                   _ind = 8;
				 if(j == col - 1)                             _ind = 7;
				 if(index == _len - 1)                        _ind = 9;
			}
		}
		
		_palInd[index] = _ind;
		drawColor(_p.color, _pdx, _pdy, _pw, _ph, true, _ind);
		
		if(sHOVER && point_in_rectangle(mouse_mx, mouse_my, _kx, _ky, _kx + ww, _ky + hh)) {
			hover = index;
			hvx = _kx;
			hvy = _ky;
			
			if(_selecting && !point_in_rectangle(mouse_mx, mouse_my, _kx + 4, _ky + 4, _kx + ww - 8, _ky + hh - 8))
				_hedge = true;
		}
	}
	
	surface_set_target(selection_surface);
		DRAW_CLEAR
		for(var i = 0; i < row; i++)
		for(var j = 0; j < col; j++) {
			var index = i * col + j;
			if(index >= _len) break;
			
			if(index >= index_selecting[0] && index < index_selecting[0] + index_selecting[1]) {
				var _p  = paletteObject[index];
				var _px = dialog_x + _p.x - pl_sx;
				var _py = dialog_y + _p.y - pl_sy;
				
				drawColor(_p.color, _px, _py, _pw, _ph, true, _palInd[index]);
			}
		}
	surface_reset_target();
	
	shader_set(sh_dialog_palette_selector);
		shader_set_f("dimension",     pl_sw, pl_sh);
		shader_set_i("edge",          (_hedge && !mouse_click(mb_left)) || index_dragging != noone);
		shader_set_color("edgeColor", COLORS._main_accent);
		
		draw_surface(selection_surface, pl_sx, pl_sy);
	shader_reset();
	
	if(mixer == noone) {
		if(index_dragging != noone) {
			if(hover > -1 && hover != index_dragging) {
				
				var prea = [];
				var cont = [];
				var posa = [];
				
				var _0 = index_selecting[0];
				var _1 = index_selecting[0] + index_selecting[1];
				var _2 = array_length(paletteObject);
				
				for(var i = 0; i < _2; i++) {
						 if(i < _0) array_push(prea, paletteObject[i]);
					else if(i < _1) array_push(cont, paletteObject[i]);
					else            array_push(posa, paletteObject[i]);
				}
				
				var _shf = clamp(hover - index_dragging, -index_selecting[0], _2 - (index_selecting[0] + index_selecting[1]));
				var _pal = [];
				
				if(_shf < 0) {
					for (var i = 0, n = array_length(prea) + _shf; i < n; i++)              		array_push(_pal, prea[i]);
					for (var i = 0, n = array_length(cont); i < n; i++)                     		array_push(_pal, cont[i]);
					for (var i = array_length(prea) + _shf, n = array_length(prea); i < n; i++)		array_push(_pal, prea[i]);
					for (var i = 0, n = array_length(posa); i < n; i++)                     		array_push(_pal, posa[i]);
					
					paletteObject = _pal;
					
				} else if(_shf > 0) {
					for (var i = 0, n = array_length(prea); i < n; i++)                     		array_push(_pal, prea[i]);
					for (var i = 0, n = _shf; i < n; i++)                                   		array_push(_pal, posa[i]);
					for (var i = 0, n = array_length(cont); i < n; i++)                     		array_push(_pal, cont[i]);
					for (var i = _shf, n = array_length(posa); i < n; i++)                  		array_push(_pal, posa[i]);
					
					paletteObject = _pal;
					
				}
				
				index_selecting[0] += _shf;
				index_dragging      = hover;
				refreshPalette();
			}
			
			if(mouse_release(mb_left)) {
				index_selecting = [ 0, 0 ];
				index_dragging  = noone;
			}
				
		} else {
			index_drag_x = 0;
			index_drag_y = 0;
			index_drag_w = 0;
			index_drag_h = 0;
		
			if(hover > -1) {
				
				if(mouse_press(mb_left, sFOCUS)) {
					
					if(interactable) {
						if(_hedge) index_dragging = hover;
						else {
							index_selecting = [ hover, 1 ];
							selector.setColor(palette[hover]);
						}
						
					} else if(!interactable) {
						index_selecting = [ hover, 1 ];
						selector.setColor(palette[hover]);
					}
					
					mouse_interact  = true;
					index_sel_start = hover;
					
				} else if(mouse_click(mb_left, sFOCUS) && mouse_interact) {
					
					if(hover > index_sel_start) {
						index_selecting[0] = index_sel_start;
						index_selecting[1] = hover - index_sel_start + 1;
						
					} else if(hover < index_sel_start) {
						index_selecting[0] = hover;
						index_selecting[1] = index_sel_start - hover + 1;
						
					} else {
						index_selecting[0] = hover;
						index_selecting[1] = 1;
					}
				}
				
			}
		}
	}
	
	if(mouse_release(mb_left)) mouse_interact = false;
	
	selector.current_colors = noone;
	if(index_selecting[1] > 1) {
		colors_selecting = array_verify(colors_selecting, index_selecting[1]);
		for(var i = 0; i < index_selecting[1]; i++)
			colors_selecting[i] = palette[index_selecting[0] + i];
		selector.current_colors = colors_selecting;
	}
	
	var bx   = content_x + content_w - ui(50);
	var by   = pl_y - ui(2);
	var _foc = interactable && sFOCUS;
	
	if(array_length(palette) > 1) {
		if(buttonInstant(THEME.button_hide_fill, bx, by, ui(28), ui(28), mouse_ui, sHOVER, _foc, "", THEME.minus_16) == 2) {
			array_delete(palette, index_selecting[0], index_selecting[1]);
			if(array_empty(palette)) palette = [ cola(c_black) ];
			index_selecting = [ 0, 0 ];
			
			refreshPaletteObject();
			onApply(palette);
		}
	} else
		draw_sprite_ui_uniform(THEME.minus, 0, bx + ui(14), by + ui(14), 1, COLORS._main_icon, 0.5);
	
	bx -= ui(32);
	if(buttonInstant(THEME.button_hide_fill, bx, by, ui(28), ui(28), mouse_ui, sHOVER, _foc, "", THEME.add_16) == 2) {
		palette[array_length(palette)] = cola(c_black);
		index_selecting = [ array_length(palette), 1 ];
		
		refreshPaletteObject();
		onApply(palette);
	}
	
	bx = content_x + ui(18);
	if(buttonInstant(THEME.button_hide_fill, bx, by, ui(28), ui(28), mouse_ui, sHOVER, _foc, __txtx("palette_editor_load", "Load palette file") + " (.hex)", THEME.file) == 2) {
		var path = get_open_filename_pxc("HEX palette|*.hex", "");
		key_release();
		
		if(isPaletteFile(path)) {
			palette = loadPalette(path);
			refreshPaletteObject();
			
			onApply(palette);
		}
	}
	draw_sprite_ui_uniform(THEME.file, 0, bx + ui(14), by + ui(14), 1, COLORS._main_icon);
#endregion

#region selector
	var con_x = content_x + ui(20);
	var con_y = dialog_y  + ui(70) + pl_h;
		
	var con_w = content_w - ui(40);
	var con_h = dialog_h  - (ui(70) + pl_h + ui(64));
		
	if(mixer != noone) {
		mixer_surface = surface_verify(mixer_surface, con_w, con_h);
		mixer.w = con_w;
		mixer.h = con_h;
		
		mixer.mx = mouse_mx - con_x;
		mixer.my = mouse_my - con_y;
		
		mixer.pHOVER = sHOVER;
		mixer.pFOCUS = sFOCUS;
		
		surface_set_target(mixer_surface);
			mixer.drawContent();
		surface_reset_target();
		
		draw_surface(mixer_surface, con_x, con_y);
		
	} else {
		selector.draw(con_x, con_y, sFOCUS, sHOVER);
		
	}
#endregion

#region controls
	var bx = content_x + content_w - ui(36);
	var by = dialog_y + dialog_h - ui(36);
	
	b_apply.register();
	b_apply.setFocusHover(sFOCUS, sHOVER);
	b_apply.draw(bx - ui(18), by - ui(18), ui(36), ui(36), mouse_ui, THEME.button_lime);
	
	bx -= ui(48);
	b_cancel.register();
	b_cancel.setFocusHover(sFOCUS, sHOVER);
	b_cancel.draw(bx - ui(18), by - ui(18), ui(36), ui(36), mouse_ui, THEME.button_hide_fill);
#endregion