/// @description init
#region pos
	var hght = line_get_height(font, 8);
	var hh = array_length(data) * hght;
	
	dialog_h = min(max_h, hh);
	sc_content.resize(dialog_w, dialog_h);
#endregion
event_inherited();