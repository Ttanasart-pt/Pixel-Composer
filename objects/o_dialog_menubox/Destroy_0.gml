event_inherited();

if(instance_exists(submenu)) 
	instance_destroy(submenu);

if(FOCUS == noone && instance_number(o_dialog_menubox) == 1) FOCUS = FOCUS_BEFORE;