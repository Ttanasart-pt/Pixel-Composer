/// @description init
event_inherited();

#region data
	project = noone;
	
	title   = __txt($"Project modified");
	content = __txtx("dialog_exit_content", "Save progress before close?");
	
	buttons = [
		[ __txt("Save"),       function() /*=>*/ { SAVE(project); closeProject(project); }, COLORS._main_value_positive ],
		[ __txt("Don't Save"), function() /*=>*/ { closeProject(project); }, COLORS._main_value_negative ],
		[ __txt("Cancel"),     function() /*=>*/ {}, c_white ],
	];
#endregion