/// @description init
event_inherited();

#region data
	project  = noone;
	dialog_w = ui(400);
	dialog_h = ui(140);
	
	buttonIndex = 0;
	buttons = [
		[ __txt("Save"), function() /*=>*/ { 
			SAVE(project);
			closeProject(project);
		} ],
		
		[ __txt("Don't Save"), function() /*=>*/ { 
			closeProject(project);
		} ],
		
		[ __txt("Cancel"), function() /*=>*/ {} ],
		
	];
	
#endregion