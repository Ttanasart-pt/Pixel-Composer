/// @description init
if !ready exit;
if palette == 0 exit;

#region dropper
	selector.interactable = interactable;
	if(selector.dropper_active) {
		selector.drawDropper(self);
		exit;
	}
#endregion

#region base UI
	var presets_x  = dialog_x;
	var presets_w  = ui(240);
	
	var content_x = dialog_x + presets_w + ui(16);
	var content_w = dialog_w - presets_w - ui(16);
	
	draw_sprite_stretched(THEME.dialog_bg, 0, presets_x, dialog_y, presets_w, dialog_h);
	if(sFOCUS) draw_sprite_stretched_ext(THEME.dialog_active, 0, presets_x, dialog_y, presets_w, dialog_h, COLORS._main_accent, 1);
	
	draw_sprite_stretched(THEME.dialog_bg, 0, content_x, dialog_y, content_w, dialog_h);
	if(sFOCUS) draw_sprite_stretched_ext(THEME.dialog_active, 0, content_x, dialog_y, content_w, dialog_h, COLORS._main_accent, 1);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	draw_text(presets_x + ui(24), dialog_y + ui(16), __txt("Presets"));
	draw_text(content_x + (!interactable * ui(32)) + ui(24), dialog_y + ui(16), name);
	if(!interactable)
		draw_sprite_ui(THEME.lock, 0, content_x + ui(24 + 12), dialog_y + ui(16 + 12),,,, COLORS._main_icon);
#endregion

#region presets
	draw_sprite_stretched(THEME.ui_panel_bg, 0, presets_x + ui(16), dialog_y + ui(44), ui(240 - 32), dialog_h - ui(60));
	
	sp_presets.setFocusHover(sFOCUS, sHOVER);
	sp_presets.draw(presets_x + ui(24), dialog_y + ui(44));
	
	var bx = presets_x + presets_w - ui(44);
	var by = dialog_y + ui(12);
	
	if(buttonInstant(THEME.button_hide, bx, by, ui(28), ui(28), mouse_ui, sFOCUS, sHOVER, __txtx("add_preset", "Add to preset"), THEME.add) == 2) {
		var dia = dialogCall(o_dialog_file_name, mouse_mx + ui(8), mouse_my + ui(8));
		dia.onModify = function (txt) {
			var file = file_text_open_write(txt + ".hex");
			for(var i = 0; i < array_length(palette); i++) {
				var cc = palette[i];
				var r  = number_to_hex(color_get_red(cc));
				var g  = number_to_hex(color_get_green(cc));
				var b  = number_to_hex(color_get_blue(cc));
				
				file_text_write_string(file, r + g + b);
				file_text_writeln(file);
			}
			file_text_close(file);
			presetCollect();
		};
		dia.path = DIRECTORY + "Palettes/"
	}
	bx -= ui(32);
	
	if(buttonInstant(THEME.button_hide, bx, by, ui(28), ui(28), mouse_ui, sFOCUS, sHOVER, __txt("Refresh"), THEME.refresh) == 2) {
		presetCollect();
	}
	draw_sprite_ui_uniform(THEME.refresh, 0, bx + ui(14), by + ui(14), 1, COLORS._main_icon);
	bx -= ui(32);
	
	if(buttonInstant(THEME.button_hide, bx, by, ui(28), ui(28), mouse_ui, sFOCUS, sHOVER, __txtx("color_selector_open_palette", "Open palette folder"), THEME.folder) == 2) {
		var _realpath = DIRECTORY + "Palettes";
		shellOpenExplorer(_realpath)
	}
	draw_sprite_ui_uniform(THEME.folder, 0, bx + ui(14), by + ui(14), 1, COLORS._main_icon);
	bx -= ui(32);
#endregion

#region palette
	var pl_x = content_x + ui(60);
	var pl_y = dialog_y + ui(54);
	var pl_w = content_w - ui(154);
	var pl_h = ui(24);
	
	var max_col = 8;
	var col = min(array_length(palette), max_col);
	var row = ceil(array_length(palette) / col);
	var ww = round(pl_w / col);
	var hh = (pl_h + ui(6)) * row;
	dialog_h = ui(408) + hh;
	
	draw_sprite_stretched(THEME.textbox, 3, pl_x - ui(6), pl_y - ui(6), pl_w + ui(12), hh + ui(6));
	draw_sprite_stretched(THEME.textbox, 0, pl_x - ui(6), pl_y - ui(6), pl_w + ui(12), hh + ui(6));
	
	#region tools
		var bx = content_x + content_w - ui(50);
		var by = dialog_y + ui(16);
		
		if(buttonInstant(THEME.button_hide, bx, by, ui(28), ui(28), mouse_ui, interactable && sFOCUS, sHOVER, __txtx("palette_editor_sort", "Sort color"), THEME.sort) == 2) {
			menuCall("palette_window_sort_menu", bx + ui(32), by, [ 
				menuItem(__txtx("palette_editor_sort_brighter", "Brighter"), function() { sortPalette(__sortBright); }), 
				menuItem(__txtx("palette_editor_sort_darker", "Darker"),     function() { sortPalette(__sortDark); }),
				-1,
				menuItem(__txtx("palette_editor_sort_hue", "Hue"),           function() { sortPalette(__sortHue); }), 
				menuItem(__txtx("palette_editor_sort_sat", "Saturation"),    function() { sortPalette(__sortSat); }), 
				menuItem(__txtx("palette_editor_sort_val", "Value"),         function() { sortPalette(__sortVal); }), 
			],, palette);
		}
		bx -= ui(32);
		
		if(buttonInstant(THEME.button_hide, bx, by, ui(28), ui(28), mouse_ui, interactable && sFOCUS, sHOVER, __txtx("palette_editor_reverse", "Reverse palette"), THEME.reverse) == 2) {
			palette = array_reverse(palette);
			onApply(palette);
		}
		bx -= ui(32);
	#endregion
	
	var hover = -1, hvx, hvy;
	for(var i = 0; i < row; i++)
	for(var j = 0; j < col; j++) {
		var index = i * col + j;
		if(index >= array_length(palette)) break;
		var _p  = palette[index];
		var _kx = pl_x + j * ww;
		var _ky = pl_y + i * (pl_h + ui(6));
		
		draw_sprite_stretched_ext(THEME.color_picker_sample, index == index_selecting, _kx + ui(2), _ky, ww - ui(4), pl_h, _p, 1);
		
		if(sHOVER && point_in_rectangle(mouse_mx, mouse_my, _kx, _ky, _kx + ww, _ky + pl_h)) {
			hover = index;
			hvx = _kx;
			hvy = _ky;
		}
	}
	
	if(index_dragging > -1) {
		if(hover > -1 && hover != index_dragging) {
			draw_set_color(COLORS.dialog_palette_divider);
			if(hover < index_dragging)
				draw_line_width(hvx - 1, hvy, hvx - 1, hvy + pl_h, 4);
			else
				draw_line_width(hvx + ww - 1, hvy, hvx + ww - 1, hvy + pl_h, 4);
			
			if(mouse_release(mb_left)) {
				var tt = palette[index_dragging];
				
				array_delete(palette, index_dragging, 1);
				array_insert(palette, hover, tt);
				index_selecting = hover;
				
				onApply(palette);
			}
		}
		
		if(mouse_release(mb_left))
			index_dragging = -1;	
	}
	
	if(mouse_press(mb_left, sFOCUS) && hover > -1) {
		index_selecting = hover;
		if(interactable)
			index_dragging = hover;
		selector.setColor(palette[hover]);
	}
	
	var bx = content_x + content_w - ui(50);
	var by = pl_y - ui(2);
	
	if(array_length(palette) > 1) {
		if(buttonInstant(THEME.button, bx, by, ui(28), ui(28), mouse_ui, interactable && sFOCUS, sHOVER, "", THEME.minus) == 2) {
			array_delete(palette, index_selecting, 1);
			index_selecting = clamp(index_selecting - 1, 0, array_length(palette) - 1);
			onApply(palette);
		}
	} else {
		draw_sprite_ui_uniform(THEME.minus, 0, bx + ui(14), by + ui(14), 1, COLORS._main_icon, 0.5);
	}
	
	bx -= ui(32);
	if(buttonInstant(THEME.button, bx, by, ui(28), ui(28), mouse_ui, interactable && sFOCUS, sHOVER, "", THEME.add) == 2) {
		index_selecting = array_length(palette);
		palette[array_length(palette)] = c_black;
		onApply(palette);
	}
	
	bx = content_x + ui(18);
	if(buttonInstant(THEME.button, bx, by, ui(28), ui(28), mouse_ui, interactable && sFOCUS, sHOVER, __txtx("palette_editor_load", "Load palette file") + " (.hex)", THEME.file) == 2) {
		var path = get_open_filename(".hex", "");
		key_release();
		if(path != "") {
			palette = loadPalette(path);
			onApply(palette);
		}
	}
	draw_sprite_ui_uniform(THEME.file, 0, bx + ui(14), by + ui(14), 1, COLORS._main_icon);
#endregion

#region selector
	var col_x = content_x + ui(20);
	var col_y = dialog_y + ui(70) + hh;
	
	selector.draw(col_x, col_y, sFOCUS, sHOVER);
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
	b_cancel.draw(bx - ui(18), by - ui(18), ui(36), ui(36), mouse_ui, THEME.button_hide);
#endregion