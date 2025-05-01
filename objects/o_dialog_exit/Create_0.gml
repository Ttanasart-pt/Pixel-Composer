/// @description init
event_inherited();

#region data
	project  = PROJECT;
	dialog_w = ui(440);
	dialog_h = ui(140);
	
	buttonIndex = 0;
	buttons = [
		[ __txt("Save"), function() /*=>*/ { 
			SAVE(project)
			if(instance_number(o_dialog_exit) == 1) 
				close_program(); 
		} ],
		
		[ __txt("Don't Save"), function() /*=>*/ { 
			if(instance_number(o_dialog_exit) == 1) 
				close_program(); 
		} ],
		
		[ __txt("Cancel"), function() /*=>*/ {} ],
		
	];
	
	function resetPosition() {
		if(!active) return;
		dialog_x = xstart - dialog_w / 2;
		dialog_y = ystart - dialog_h / 2;
		
		dialog_x = round(clamp(dialog_x, 2, WIN_SW - dialog_w - 2));
		dialog_y = round(clamp(dialog_y, 2, WIN_SH - dialog_h - 2));
	}
	
#endregion