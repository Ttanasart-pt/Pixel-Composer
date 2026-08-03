function canvas_s_tool_eraser() : canvas_s_tool_pencil() constructor {
	icon     = THEME.canvas_tools_eraser;
	tooltip  = "Eraser";
	hotkey   = new KeyCombination("E");
	isDrawer = true;
	
	erase = true;
	pixel_perfect = false;
}