/// @description init
#region widget scroll
	if(keyboard_check_pressed(vk_tab) && keyboard_check(vk_shift))
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
	if(PANEL_MAIN != 0)
		PANEL_MAIN.draw();
	else 
		setPanel();
#endregion