/// @description init
if !ready exit;

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
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	draw_text(presets_x + ui(24), dialog_y + ui(16), __txt("Palettes"));
	draw_text(content_x + (!interactable * ui(32)) + ui(24), dialog_y + ui(16), name);
	if(!interactable)
		draw_sprite_ui(THEME.lock, 0, content_x + ui(24 + 12), dialog_y + ui(16 + 12),,,, COLORS._main_icon);
#endregion

#region palette
	draw_sprite_stretched(THEME.ui_panel_bg, 1, presets_x + pal_padding, dialog_y + ui(48), ui(240) - pal_padding * 2, dialog_h - ui(48) - pal_padding);
	
	sp_presets.setFocusHover(sFOCUS, sHOVER);
	sp_presets.draw(presets_x + pal_padding + ui(4), dialog_y + ui(48) + ui(4));
	
	var bx = presets_x + presets_w - ui(44);
	var by = dialog_y + ui(12);
	var bs = ui(28);
	
	if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mouse_ui, sHOVER, sFOCUS, __txt("Refresh"), THEME.refresh_20) == 2)
		__initPalette();
	bx -= ui(32);
	
	if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mouse_ui, sHOVER, sFOCUS, __txtx("color_selector_open_palette", "Open palette folder"), THEME.path_open_20) == 2)
		shellOpenExplorer($"{DIRECTORY}Palettes");
	draw_sprite_ui_uniform(THEME.path_open_20, 1, bx + bs / 2, by + bs / 2, 1, c_white);
	bx -= ui(32);
	
	if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mouse_ui, sHOVER, sFOCUS, __txt("Show on Selector"), THEME.display_palette, NODE_COLOR_SHOW_PALETTE, c_white) == 2)
		NODE_COLOR_SHOW_PALETTE = !NODE_COLOR_SHOW_PALETTE;
	bx -= ui(32);
#endregion

#region selector
	var col_x = content_x + ui(20);
	var col_y = dialog_y + ui(52);
	
	if(preset_selecting > -1)
		selector.palette = PALETTES[preset_selecting].palette;
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
	b_cancel.draw(bx - ui(18), by - ui(18), ui(36), ui(36), mouse_ui, THEME.button_hide_fill);
#endregion