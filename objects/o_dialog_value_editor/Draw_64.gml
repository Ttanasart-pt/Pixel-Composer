/// @description init
if(editWidget == noone) exit;

#region Draw
	draw_sprite_stretched(THEME.textbox, 3, dialog_x, dialog_y, dialog_w, dialog_h);
	draw_sprite_stretched(THEME.textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
	
	editWidget.setFocusHover(sFOCUS, sHOVER);
	
	var eX = dialog_x + ui(4);
	var eY = dialog_y + ui(4);
	var eW = dialog_w - ui(8);
	
	var param = new widgetParam(eX, eY, eW, TEXTBOX_HEIGHT, keyframe.value, junction.display_data);
	if(is(editWidget, checkBox)) param.halign = fa_center;
	
	var _h = editWidget.drawParam(param);
	dialog_h = _h + ui(8);
	
	if(wid_h != dialog_h) {
		dialog_y = min(dialog_y, WIN_H - dialog_h - ui(8));
		wid_h = dialog_h;
	}
	
#endregion