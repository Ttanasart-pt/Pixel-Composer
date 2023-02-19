/// @description init
#region widget scroll
	if(keyboard_check_pressed(vk_tab) && key_mod_press(SHIFT))
		widget_previous();
	else if(keyboard_check_pressed(vk_tab))
		widget_next();
	
	if(keyboard_check_pressed(vk_enter))
		widget_trigger();
		
	if(keyboard_check_pressed(vk_escape))
		widget_clear();
#endregion

#region register UI element
	WIDGET_ACTIVE = [];
#endregion

#region panels
	if(PANEL_MAIN == 0) setPanel();
	
	var surf = surface_get_target();
	try
		PANEL_MAIN.draw();
	catch(e) {
		while(surface_get_target() != surf)
			surface_reset_target();
		noti_warning(exception_print(e));
	}
#endregion