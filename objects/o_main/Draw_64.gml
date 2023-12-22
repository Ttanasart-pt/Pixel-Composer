/// @description init
if(winMan_isMinimized()) exit;

if(APP_SURF_OVERRIDE) {
	APP_SURF      = surface_verify(APP_SURF,      WIN_W, WIN_H);
	PRE_APP_SURF  = surface_verify(PRE_APP_SURF,  WIN_W, WIN_H);
	POST_APP_SURF = surface_verify(POST_APP_SURF, WIN_W, WIN_H);

	surface_set_target(APP_SURF);
}

draw_clear(COLORS.bg);

#region widget scroll
	if(!WIDGET_TAB_BLOCK) {
		if(keyboard_check_pressed(vk_tab) && key_mod_press(SHIFT))
			widget_previous();
		else if(keyboard_check_pressed(vk_tab))
			widget_next();
	
		if(keyboard_check_pressed(vk_enter))
			widget_trigger();
		
		if(keyboard_check_pressed(vk_escape))
			widget_clear();
	}
	
	WIDGET_TAB_BLOCK = false;
#endregion

#region register UI element
	WIDGET_ACTIVE = [];
#endregion

#region panels
	if(PANEL_MAIN == 0) resetPanel();
	
	var surf = surface_get_target();
	try {
		PANEL_MAIN.draw();
	} catch(e) { 
		while(surface_get_target() != surf)
			surface_reset_target();
		
		noti_warning(exception_print(e));
	}
	
	panelDraw();
#endregion

#region notes
	for( var i = 0, n = array_length(PROJECT.notes); i < n; i++ )
		PROJECT.notes[i].draw();
#endregion

#region window
	winManDraw();
#endregion

if(APP_SURF_OVERRIDE) {
	surface_reset_target();
	draw_surface(POST_APP_SURF, 0, 0);
	
	surface_set_target(PRE_APP_SURF);
		draw_surface(APP_SURF, 0, 0);
	surface_reset_target();
}