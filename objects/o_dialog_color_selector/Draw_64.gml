/// @description init
if !ready exit;
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
	if(sFOCUS) 
		draw_sprite_stretched_ext(THEME.dialog, 1, presets_x - p, dialog_y - p, presets_w + p2, dialog_h + p2, COLORS._main_accent, 1);
	
	draw_sprite_stretched(THEME.dialog, 0, content_x - p, dialog_y - p, content_w + p2, dialog_h + p2);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog, 1, content_x - p, dialog_y - p, content_w + p2, dialog_h + p2, COLORS._main_accent, 1);
	
	draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text);
	draw_text(presets_x + ui(24), dialog_y + ui(16), __txt("Palettes"));
	draw_text(content_x + (!interactable * ui(32)) + ui(24), dialog_y + ui(16), name);
	if(!interactable)
		draw_sprite_ui(THEME.lock, 0, content_x + ui(24 + 12), dialog_y + ui(16 + 12),,,, COLORS._main_icon);
#endregion

#region palette
	draw_sprite_stretched(THEME.ui_panel_bg, 1, presets_x + pal_padding, dialog_y + ui(48), ui(240) - pal_padding * 2, dialog_h - ui(48) - pal_padding);
	
	var _px = presets_x + pal_padding + ui(4);
	var _py = dialog_y + ui(48 + 4);
	var _pw = sp_preset_w;
	
	draw_sprite_stretched_ext(THEME.textbox, 1, _px, _py, _pw, ui(24), COLORS._main_icon);
	tb_search.setFocusHover(sFOCUS, sHOVER);
	tb_search.draw(_px, _py, _pw, ui(24), search_string);
	draw_sprite_ui(THEME.search, 0, _px + ui(12), _py + ui(12), .75, .75, 0, COLORS._main_icon, .5);
	
	sp_presets.setFocusHover(sFOCUS, sHOVER);
	sp_presets.verify(_pw, dialog_h - ui(72 + 24));
	sp_presets.draw(_px, _py + ui(24 + 8));
	
	var bs  = ui(24);
	var bx  = presets_x + presets_w - bs - ui(12);
	var by  = dialog_y + ui(14);
	var bb  = THEME.button_hide_fill;
	var hov = sHOVER, foc = sFOCUS;
	var m   = mouse_ui;
	var bc  = COLORS._main_icon;
	
	var b = buttonInstant_Pad(bb, bx, by, bs, bs, m, hov, foc, __txt("Refresh"), THEME.refresh_icon, 0, bc, 1, ui(4));
	if(b == 2) __refreshPalette();
	draggable = draggable && !b;
	bx -= bs + ui(2);
	
	var b = buttonInstant_Pad(bb, bx, by, bs, bs, m, hov, foc, __txt("View settings..."), THEME.sort_v, 0, bc, 1, ui(4));
	if(b == 2) with menuCall("", menu_preset_sort, bx + bs, by + bs) close_on_trigger = false;
	draggable = draggable && !b;
	bx -= bs + ui(2);
	
	var t = __txtx("color_selector_open_palette", "Open palette folder");
	var b = buttonInstant_Pad(bb, bx, by, bs, bs, m, hov, foc, t, THEME.dPath_open_20, 0, bc, 1, 0);
	if(b == 2) shellOpenExplorer($"{DIRECTORY}Palettes");
	draggable = draggable && !b;
	bx -= bs + ui(2);
	
	var t = __txt("Show on Selector");
	var b = buttonInstant_Pad(bb, bx, by, bs, bs, m, hov, foc, t, THEME.display_palette, NODE_COLOR_SHOW_PALETTE, c_white, 1, ui(4));
	if(b == 2) NODE_COLOR_SHOW_PALETTE = !NODE_COLOR_SHOW_PALETTE;
	draggable = draggable && !b;
	bx -= bs + ui(2);
	
#endregion

#region selector
	var col_x = content_x + ui(20);
	var col_y = dialog_y  + ui(52);
	
	if(preset_selecting != undefined) selector.palette = preset_selecting;
	selector.draw(col_x, col_y, [mouse_mx, mouse_my], sFOCUS, sHOVER);
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