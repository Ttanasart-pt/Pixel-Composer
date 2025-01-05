/// @description init
if !ready exit;

#region base UI
	DIALOG_DRAW_BG
	if(DIALOG_SHOW_FOCUS) DIALOG_DRAW_FOCUS
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	draw_text(dialog_x + ui(24), dialog_y + ui(20), __txt("Presets"));
#endregion

#region preset
	var px = dialog_x + ui(padding);
	var py = dialog_y + ui(title_height);
	var pw = dialog_w - ui(padding + padding);
	var ph = dialog_h - ui(title_height + padding)
	
	draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
	sc_presets.setFocusHover(sFOCUS, sHOVER);
	sc_presets.draw(px, py);
	
	var bx = dialog_x + dialog_w - ui(32 + 16);
	var by = dialog_y + ui(16);
			
	if(buttonInstant(THEME.button_hide_fill, bx, by, ui(32), ui(32), mouse_ui, sHOVER, sFOCUS, __txtx("preset_new", "New preset"), THEME.add, 1) == 2) {
		adding = !adding;
		if(adding) tb_add.activate();
	}
#endregion