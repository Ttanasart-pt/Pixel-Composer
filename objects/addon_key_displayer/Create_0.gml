/// @description 
event_inherited();

#region keys
	name      = "Key display";
	alpha     = 0;
	depth     = -999;
	disp_key  = "";
	disp_keys = [];
	
	last_key  = 0;
	last_char = "";
	
	show_doubleclick = false;
	show_graph		 = false;
	
	menu = [
		menuItem("Toggle double click bar", function() /*=>*/ { show_doubleclick = !show_doubleclick; }),
		menuItem("Toggle graph",            function() /*=>*/ { show_graph       = !show_graph;       }),
	];
	
	mouse_left  = [];
	mouse_right = [];
	
	mouse_pos = [];
#endregion