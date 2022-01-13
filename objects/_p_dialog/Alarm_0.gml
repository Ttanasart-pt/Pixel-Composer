/// @description init
#region anchor
	if(anchor == ANCHOR.none) {
		dialog_x = x - dialog_w / 2;
		dialog_y = y - dialog_h / 2;
	} else {
		if(anchor & ANCHOR.left)   dialog_x = min(x, WIN_W - dialog_w);
		if(anchor & ANCHOR.right)  dialog_x = max(x - dialog_w, 0);
		if(anchor & ANCHOR.top)    dialog_y = min(y, WIN_H - dialog_h);
		if(anchor & ANCHOR.bottom) dialog_y = max(y - dialog_h, 0);
	}
#endregion

dialog_x = round(dialog_x);
dialog_y = round(dialog_y);
ready = true;