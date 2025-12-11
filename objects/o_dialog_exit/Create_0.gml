/// @description init
event_inherited();

#region data
	project  = PROJECT;
	dialog_w = ui(440);
	dialog_h = ui(128);
	padding  = ui(16);
	
	buttonIndex = 0;
	buttons = [
		[ __txt("Save"),       function() /*=>*/ { SAVE(project); if(instance_number(o_dialog_exit) == 1) Program_Close(); }, COLORS._main_value_positive ],
		[ __txt("Don't Save"), function() /*=>*/ { if(instance_number(o_dialog_exit) == 1) Program_Close(); }, COLORS._main_value_negative ],
		[ __txt("Cancel"),     function() /*=>*/ {}, c_white ],
	];
	
	function resetPosition() {
		if(!active) return;
		dialog_x = xstart - dialog_w / 2;
		dialog_y = ystart - dialog_h / 2;
		
		dialog_x = round(clamp(dialog_x, 2, WIN_SW - dialog_w - 2));
		dialog_y = round(clamp(dialog_y, 2, WIN_SH - dialog_h - 2));
	}
#endregion