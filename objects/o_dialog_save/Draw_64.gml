/// @description init
if !ready exit;
WIDGET_TAB_BLOCK = true;

#region base UI
	draw_set_color(c_black);
	draw_set_alpha(0.5);
	draw_rectangle(0, 0, WIN_W, WIN_H, false);
	draw_set_alpha(1);

	DIALOG_DRAW_BG
	if(DIALOG_SHOW_FOCUS) DIALOG_DRAW_FOCUS
#endregion

#region text
	var py  = dialog_y + padding;
	var txt = __txt($"Project modified");
	draw_set_text(f_sdf, fa_left, fa_top, COLORS._main_text);
	draw_text_add(dialog_x + padding + ui(8), py, txt, .5);
	py += line_get_height(noone, 0) * .5;
	
	draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text);
	draw_text(dialog_x + padding + ui(8), py, __txtx("dialog_exit_content", "Save progress before close?"));
	
	var amo = array_length(buttons);
	var bw  = (dialog_w - padding * 2 - ui(8 * (amo - 1))) / amo;
	var bh  = line_get_height(f_p2, 10);
	var bx1 = dialog_x + dialog_w - padding;
	var by1 = dialog_y + dialog_h - padding;
	var bx0 = bx1 - bw;
	var by0 = by1 - bh;
	
	var _des = false;
	if(keyboard_check_pressed(vk_tab)) buttonIndex = (buttonIndex + 1) % amo;
	
	for( var i = amo - 1; i >= 0; i-- ) {
		var _b   = buttons[i];
		var _txt = _b[0];
		var _fn  = _b[1];
		var _bc  = c_white;//_b[2];
		
		draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
		var b = buttonInstant(THEME.button_def, bx0, by0, bw, bh, mouse_ui, sHOVER, sFOCUS, "", noone, 0, 0, 0, 0, _bc);
		if(buttonIndex == i) draw_sprite_stretched_ext(THEME.button_def, 3, bx0, by0, bw, bh, COLORS._main_accent);
		draw_text(bx0 + bw / 2, by0 + bh / 2, _txt);
		
		var _trg = b == 2 || (buttonIndex == i && KEYBOARD_ENTER);
		if(_trg) { 
			_fn(); 
			_des = true;
		}
		
		bx0 -= bw + ui(8);
	}
	
#endregion

if(_des) instance_destroy();