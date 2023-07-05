/// @description init
#region pos
	var hght = line_get_height(f_p0, 8);
	var hh = array_length(FONT_INTERNAL) * hght;
	
	dialog_h = min(max_h, hh);
	sc_content.resize(dialog_w - ui(6), dialog_h);
#endregion
event_inherited();