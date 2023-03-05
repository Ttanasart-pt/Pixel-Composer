/// @description 
event_inherited();

#region keys
	name = "Key display";
	alpha = 0;
	disp_text = "";
	depth = -999;
	
	show_doubleclick = false;
	show_graph		 = false;
	
	menu = [
		menuItem("Toggle double click bar", function() { show_doubleclick = !show_doubleclick; }),
		menuItem("Toggle graph", function() { show_graph = !show_graph; }),
	];
	
	extra_keys = [
		[vk_control, "Ctrl"],
		[vk_shift, "Shift"],
		[vk_alt, "Alt"],
		[vk_tab, "Tab"],
		[vk_backspace, "Backspace"],
		[vk_delete, "Delete"],
		[vk_escape, "Escape"],
		[vk_up, "Up"],
		[vk_down, "Down"],
		[vk_left, "Left"],
		[vk_right, "Right"],
	];
	
	mouse_left = [];
#endregion