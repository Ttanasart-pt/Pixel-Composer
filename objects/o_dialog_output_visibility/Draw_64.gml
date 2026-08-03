/// @description init
if !ready exit;

DIALOG_DRAW_BG

#region base UI
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	draw_text(_dialog_x + ui(24), _dialog_y + ui(20), __txt("output_visibility_title", "Outputs visibility"));
#endregion

#region preset
	var px = _dialog_x + ui(padding);
	var py = _dialog_y + ui(title_height);
	var pw = dialog_w - ui(padding + padding);
	var ph = dialog_h - ui(title_height + padding);
	
	draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
	sc_outputs.setFocusHover(sFOCUS, sHOVER);
	sc_outputs.draw(px, py);
#endregion

DIALOG_DRAW_FOCUS