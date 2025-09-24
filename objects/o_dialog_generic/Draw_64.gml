/// @description init
if !ready exit;

#region dim BG
	if(dim_bg) {
		var lowest = true;
		with(_p_dialog) {
			if(id == other.id) continue;
			if(depth > other.depth) lowest = false;
		}
	
		if(lowest) {
			draw_set_color(c_black);
			draw_set_alpha(0.5);
			draw_rectangle(0, 0, WIN_W, WIN_H, false);
			draw_set_alpha(1);
		}
	}
#endregion

DIALOG_PREDRAW
DIALOG_WINCLEAR

DIALOG_DRAW_BG
if(DIALOG_SHOW_FOCUS) DIALOG_DRAW_FOCUS

#region text
	var py  = dialog_y + ui(16);
	var txt = __txt(title);
	draw_set_text(f_h5, fa_left, fa_top, COLORS._main_text);
	draw_text(dialog_x + ui(24), py, txt);
	py += line_get_height(, 4);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	var txt = __txt(text);
	draw_text_ext(dialog_x + ui(24), py, txt, -1, dialog_w - ui(48));
	_dialog_h = ui(118) + string_height_ext(txt, -1, dialog_w - ui(48));
	
	var bw  = ui(96), bh = BUTTON_HEIGHT;
	var bx1 = dialog_x + dialog_w - ui(16);
	var by1 = dialog_y + dialog_h - ui(16);
	var bx0 = bx1 - bw;
	var by0 = by1 - bh;
	
	var _des = false;
	if(keyboard_check_pressed(vk_tab)) buttonIndex = (buttonIndex + 1) % array_length(buttons);
	
	for( var i = array_length(buttons) - 1; i >= 0; i-- ) {
		var _b = buttons[i];
		
		draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text);
		var b = buttonInstant(THEME.button_def, bx0, by0, bw, bh, mouse_ui, sHOVER, sFOCUS);
		if(buttonIndex == i) draw_sprite_stretched_ext(THEME.button_def, 3, bx0, by0, bw, bh, COLORS._main_accent);
		draw_text(bx0 + bw / 2, by0 + bh / 2, _b[0]);
		
		var _trg = b == 2 || (buttonIndex == i && KEYBOARD_ENTER);
		if(_trg) { _b[1](); _des = true; }
		
		bx0 -= bw + ui(12);
	}
	
	dialog_h = _dialog_h;
#endregion

DIALOG_POSTDRAW

if(_des) instance_destroy();