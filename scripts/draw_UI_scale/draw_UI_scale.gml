function line_get_height(font = noone, offset = 0) {
	INLINE
	var _f = font != noone? font : draw_get_font();
	return global.LINE_HEIGHTS[$ _f] + offset * UI_SCALE;
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
	
	function resetScale(scale, willResize = false) {
		if(PREFERENCES.display_scaling == scale) return;
		
		PREFERENCES.display_scaling = scale;
		resetPanel(false);
		loadFonts();
			
		if(willResize) time_source_start(time_source_create(time_source_global, 1, time_source_units_frames, onResize));
		PREF_SAVE();
	}
#endregion