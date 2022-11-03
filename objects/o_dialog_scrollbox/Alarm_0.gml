/// @description init
#region pos
	var hght = line_height(f_p0, 8);
	var hh = array_length(scrollbox.data_list) * hght;
	
	dialog_h = hh;
#endregion
event_inherited();