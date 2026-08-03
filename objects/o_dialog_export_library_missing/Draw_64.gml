/// @description init
if !ready exit;

#region dim BG
	var lowest = true;

	draw_set_color(c_black);
	draw_set_alpha(0.5);
	draw_rectangle(0, 0, WIN_W, WIN_H, false);
	draw_set_alpha(1);
#endregion

DIALOG_DRAW_BG

#region text
	var py  = _dialog_y + ui(20);
	var txt = $"Missing {lib} Library";
	draw_set_text(f_sdf, fa_left, fa_top, COLORS._main_text);
	draw_text_add(_dialog_x + ui(24), py, txt, .5);
	py += line_get_height(noone, 8) * .5;
	
	draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text_sub);
	draw_text_ext(_dialog_x + ui(24), py, ctxt[0], -1, dialog_w - ui(48));
	py += string_height_ext(ctxt[0], -1, dialog_w - ui(48)) + ui(16);
	
	draw_set_text(f_code, fa_left, fa_top, COLORS._main_text);
	var _hh = string_height_ext_override(ctxt[1], -1, dialog_w - ui(64), true);
	draw_sprite_stretched(THEME.ui_panel_bg, 1, _dialog_x + ui(24), py - ui(8), dialog_w - ui(48), _hh + ui(16));
	
	draw_text_line(_dialog_x + ui(32), py, ctxt[1], -1, dialog_w - ui(64), true);
	py += _hh + ui(16);
	
	draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text_sub);
	draw_text_ext(_dialog_x + ui(24), py, ctxt[2], -1, dialog_w - ui(48));
	py += string_height_ext(ctxt[2], -1, dialog_w - ui(48));
	
	var bpad = ui(THEME_VALUE.dialog_modal_button_spacing);
	var bamo = 3;
	
	var bw = bpad > 0? ui(160) : (dialog_w - DIALOG_PAD - bpad) / bamo;
	var bh = BUTTON_HEIGHT;
	var bx1 = _dialog_x + dialog_w - DIALOG_PAD / bamo - bpad;
	var by1 = _dialog_y + dialog_h - DIALOG_PAD / bamo - bpad;
	var bx0 = bx1 - bw;
	var by0 = by1 - bh;
	
	draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text);
	var b = buttonInstant(THEME.button_def, bx0, by0, bw, bh, mouse_ui, sHOVER, sFOCUS);
	draw_text_add(bx0 + bw / 2, by0 + bh / 2, __txt("Cancel"));
	if(b == 2) instance_destroy();
	
	bx0 -= bw + bpad;
	var b = buttonInstant(THEME.button_def, bx0, by0, bw, bh, mouse_ui, sHOVER, sFOCUS);
	draw_text_add(bx0 + bw / 2, by0 + bh / 2, __txt("Open Target Folder"));
	if(b == 2) shellOpenExplorer(filename_dir(file));
	
	bx0 -= bw + bpad;
	var b = buttonInstant(THEME.button_def, bx0, by0, bw, bh, mouse_ui, sHOVER, sFOCUS);
	draw_text_add(bx0 + bw / 2, by0 + bh / 2, __txt("Open Link"));
	if(b == 2) {
		URL_open(link);
		instance_destroy();
	}
#endregion

DIALOG_DRAW_FOCUS