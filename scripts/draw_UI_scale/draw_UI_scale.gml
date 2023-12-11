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
	#macro BUTTON_HEIGHT  line_get_height(f_p0, 12)

	function ui(val) { 
		INLINE
		return round(val * UI_SCALE); 
	}
	
	function resetScale(scale) {
		if(scale == PREFERENCES.display_scaling) return;
		
		PREFERENCES.display_scaling = scale;
		resetPanel();
		loadFonts();
			
		time_source_start(time_source_create(time_source_global, 1, time_source_units_frames, onResize));
		PREF_SAVE();
	}
#endregion