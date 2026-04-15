/// @description init
event_inherited();

#region data
	project = PROJECT;
    var prj = filename_name_only(project.path);
	
    title   = __txt($"Project modified");
	content = prj == ""? __txt("Save new project before exit?") : __txta("Save project '{1}' before exit?", prj);

	buttons = [
		[ __txt("Save"),       function() /*=>*/ { SAVE(project); if(instance_number(o_dialog_exit) == 1) Program_Close(); }, COLORS._main_value_positive ],
		[ __txt("Don't Save"), function() /*=>*/ { if(instance_number(o_dialog_exit) == 1) Program_Close(); }, COLORS._main_value_negative ],
		[ __txt("Cancel"),     function() /*=>*/ {}, c_white ],
	];
#endregion