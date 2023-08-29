function line_get_height(font = noone, offset = 0) {
	var ff = draw_get_font();
	
	if(font != noone)
		draw_set_font(font);
	var hh = string_height("l") + offset * UI_SCALE;
	
	draw_set_font(ff);
	return hh;
}

function line_get_width(txt, font = noone, offset = 0) {
	var ff = draw_get_font();
	
	if(font != noone)
		draw_set_font(font);
	var ww = string_width(txt) + offset * UI_SCALE;
	
	draw_set_font(ff);
	return ww;
}

#region global
	#macro TEXTBOX_HEIGHT line_get_height(f_p0, 8)

	function ui(val) { 
		gml_pragma("forceinline");
		return val * UI_SCALE; 
	}
#endregion