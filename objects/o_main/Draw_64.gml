/// @description init
if(winMan_isMinimized()) exit;

_MOUSE_BLOCK = MOUSE_BLOCK;
if(MOUSE_BLOCK) MOUSE_BLOCK--;
if(PREFERENCES.video_mode && key_press(ord("Z"), MOD_KEY.alt, true)) MOUSE_BLOCK = 1;

if(APP_SURF_OVERRIDE || DROPPER_DROPPING) {
	APP_SURF      = surface_verify(APP_SURF,      WIN_W, WIN_H);
	PRE_APP_SURF  = surface_verify(PRE_APP_SURF,  WIN_W, WIN_H);
	POST_APP_SURF = surface_verify(POST_APP_SURF, WIN_W, WIN_H);

	surface_set_target(APP_SURF);
}

draw_clear(COLORS.bg);

#region widget scroll
	if(!WIDGET_TAB_BLOCK) {
		if(keyboard_check_pressed(vk_tab)) {
			if(key_mod_check(MOD_KEY.shift)) widget_previous();
			if(key_mod_check(MOD_KEY.none))  widget_next();
			
			if(key_mod_check(MOD_KEY.ctrl))  PANEL_INSPECTOR.prop_page = !bool(PANEL_INSPECTOR.prop_page);
		}
		
		if(KEYBOARD_ENTER)
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

if(DROPPER_DROPPING) {
	surface_reset_target();
	draw_surface(APP_SURF, 0, 0);
}

if(APP_SURF_OVERRIDE) {
	surface_reset_target();
	draw_surface(POST_APP_SURF, 0, 0);
	
	surface_set_target(PRE_APP_SURF);
		draw_surface(APP_SURF, 0, 0);
	surface_reset_target();
	
	surface_set_target(POST_APP_SURF);
		draw_surface(APP_SURF, 0, 0);
	surface_reset_target();
}

#region zoom area
	if(PREFERENCES.video_mode) {
		zoom_area_draw();
		zoom_area_draw_gui();
	}
#endregion

DROPPER_DROPPING = false;