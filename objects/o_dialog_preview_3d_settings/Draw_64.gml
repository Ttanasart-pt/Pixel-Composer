/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), __txtx("preview_3d_settings", "3D Preview Settings"));
#endregion

#region draw
	var yy = dialog_y + ui(64);
	var ww = ui(200);
	var wh = TEXTBOX_HEIGHT;
	
	for( var i = 0, n = array_length(properties); i < n; i++ ) {
		var _prop = properties[i];
		
		var _widg = _prop[0];
		var _text = _prop[1];
		var _data = _prop[2]();
		
		_widg.setFocusHover(sFOCUS, sHOVER);
		_widg.register();
		
		draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
		draw_text(dialog_x + ui(32), yy, _text);
		
		var params = new widgetParam(dialog_x + dialog_w - ui(16) - ww, yy - wh / 2, ww, wh, _data);
		if(is_instanceof(_widg, checkBox)) {
			params.halign = fa_center;
			params.valign = fa_center;
		}
		
		_widg.drawParam(params);
		
		yy += ui(40);
	}
#endregion