/// @description init
if(editWidget == noone) exit;

DIALOG_WINDOW_START
#region Draw
	draw_sprite_stretched(THEME.textbox, 3, _dialog_x, _dialog_y, dialog_w, dialog_h);
	draw_sprite_stretched(THEME.textbox, 1, _dialog_x, _dialog_y, dialog_w, dialog_h);
	
	editWidget.setFocusHover(sFOCUS, sHOVER);
	
	var eX = _dialog_x + ui(4);
	var eY = _dialog_y + ui(4);
	var eW =  dialog_w - ui(8);
	
	var param = new widgetParam(eX, eY, eW, TEXTBOX_HEIGHT, keyframe.value, junction.display_data);
	
	var _h = editWidget.drawParam(param);
	dialog_h = _h + ui(8);
	
	if(wid_h != dialog_h) {
		_dialog_y = min(_dialog_y, WIN_H - dialog_h - ui(8));
		wid_h = dialog_h;
	}
	
#endregion
DIALOG_WINDOW_END