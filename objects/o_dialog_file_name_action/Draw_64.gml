/// @description init
#region base UI
	DIALOG_DRAW_BG
	if(DIALOG_SHOW_FOCUS) DIALOG_DRAW_FOCUS
#endregion

#region draw TB
		
	tb_name.setFocusHover(sFOCUS, sHOVER);		tb_name.register();
	tb_tooltip.setFocusHover(sFOCUS, sHOVER);	tb_tooltip.register();
	tb_alias.setFocusHover(sFOCUS, sHOVER); 	tb_alias.register();
	tb_location.setFocusHover(sFOCUS, sHOVER);	tb_location.register();
	
	var _pd = ui(16);
	var _nm = ui(128);
	var _wx = dialog_x + _nm;
	var _wy = dialog_y + _pd;
	var _ww = dialog_w - _pd - _nm;
	var _wh = TEXTBOX_HEIGHT;
	var _th = 0;
	
	draw_set_text(f_p0, fa_left, fa_center, COLORS._main_icon);
	draw_text_add(dialog_x + _pd, _wy + _wh / 2, __txt("Name"));
	var _hh = tb_name.draw(   	_wx, _wy, _ww - ui(72), _wh,	 name,    mouse_ui);	_wy += _hh + ui(8); _th += _hh + ui(8);
	
	draw_set_text(f_p0, fa_left, fa_center, COLORS._main_icon);
	draw_text_add(dialog_x + _pd, _wy + _wh / 2, __txt("Alias"));
	var _hh = tb_alias.draw(	_wx, _wy, _ww,			_wh,     tags,    mouse_ui);	_wy += _hh + ui(8); _th += _hh + ui(8);
	
	draw_set_text(f_p0, fa_left, fa_center, COLORS._main_icon);
	draw_text_add(dialog_x + _pd, _wy + _wh / 2, __txt("Tooltip"));
	var _hh = tb_tooltip.draw(	_wx, _wy, _ww,			_wh * 2, tooltip, mouse_ui);	_wy += _hh + ui(8); _th += _hh + ui(8);
	
	draw_set_text(f_p0, fa_left, fa_center, COLORS._main_icon);
	draw_text_add(dialog_x + _pd, _wy + _wh / 2, __txt("Categories"));
	var _hh = tb_location.draw(	_wx, _wy, _ww,			_wh,	          mouse_ui);  	_wy += _hh + ui(8); _th += _hh + ui(8);
	
	dialog_h = _th + _pd * 2 - ui(8);
	
	var bw = ui(32);
	var bh = ui(32);
	var bx = dialog_x + dialog_w - _pd - bw;
	var by = dialog_y + _pd;
	
	var txt  = __txtx("new_action_create", "Create action");
	var icon = THEME.accept;
	var clr  = COLORS._main_value_positive;
	
	if(buttonInstant(THEME.button_hide_fill, bx, by, bw, bh, mouse_ui, sHOVER, sFOCUS, txt, icon, 0, clr) == 2) {
		
	}
	
	bx -= bw + ui(4);
	
	var txt  = __txt("Cancel");
	var icon = THEME.cross;
	var clr  = COLORS._main_value_negative;
	
	if(buttonInstant(THEME.button_hide_fill, bx, by, bw, bh, mouse_ui, sHOVER, sFOCUS, txt, icon, 0, clr) == 2) {
		instance_destroy();
	}
	
#endregion