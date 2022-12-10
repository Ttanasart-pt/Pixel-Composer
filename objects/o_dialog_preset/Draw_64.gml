/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_title);
	draw_text(dialog_x + ui(24), dialog_y + ui(20), "Presets");
#endregion

#region preset
	var px = dialog_x + ui(padding);
	var py = dialog_y + ui(64);
	var pw = dialog_w - ui(padding + padding);
	var ph = dialog_h - ui(64 + padding)
	
	draw_sprite_stretched(THEME.ui_panel_bg, 0, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
	sc_presets.active = sFOCUS;
	sc_presets.draw(px, py);
	
	var bx = dialog_x + dialog_w - ui(32 + 16);
	var by = dialog_y + ui(16);
			
	if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), mouse_ui, sFOCUS, sHOVER, "New preset", THEME.add, 1) == 2) {
		var dia = dialogCall(o_dialog_file_name, mouse_mx + ui(8), mouse_my + ui(8));
		dia.onModify = newPresetFromNode;
	}
#endregion