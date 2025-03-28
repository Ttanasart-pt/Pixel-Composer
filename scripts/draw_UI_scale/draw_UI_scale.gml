function line_get_height(font = noone, offset = 0) {
	INLINE
	var _f = draw_get_font();
	
	if(font != noone) draw_set_font(font);
	var _h = string_height("l") + offset * UI_SCALE;
	draw_set_font(_f);
	
	return _h;
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
	#macro TEXTBOX_HEIGHT line_get_height(f_p1, 6)
	#macro BUTTON_HEIGHT  line_get_height(f_p1, 12)
	
	function  ui(val)     { INLINE return round(val * UI_SCALE); }
	function  ui_raw(val) { INLINE return val * UI_SCALE; }
	function _ui(val)     { INLINE return val / UI_SCALE; }
	
	function resetScale(scale, willResize = false) {
		if(PREFERENCES.display_scaling == scale) return;
		
		PREFERENCES.display_scaling = scale;
		resetPanel(false);
		loadFonts();
			
		if(willResize) time_source_start(time_source_create(time_source_global, 1, time_source_units_frames, onResize));
		PREF_SAVE();
	}
#endregion