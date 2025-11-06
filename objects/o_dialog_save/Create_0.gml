/// @description init
event_inherited();

#region data
	project  = noone;
	dialog_w = ui(400);
	dialog_h = ui(128);
	padding  = ui(16);
	
	buttonIndex = 0;
	buttons = [
		[ __txt("Save"),       function() /*=>*/ { SAVE(project); closeProject(project); }, COLORS._main_value_positive ],
		[ __txt("Don't Save"), function() /*=>*/ { closeProject(project); }, COLORS._main_value_negative ],
		[ __txt("Cancel"),     function() /*=>*/ {}, c_white ],
	];
#endregion