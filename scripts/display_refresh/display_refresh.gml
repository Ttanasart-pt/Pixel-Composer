function display_refresh() {
	o_main.win_wp      = WIN_W;
	o_main.win_hp      = WIN_H;	
	room_width  = WIN_W;
	room_height = WIN_H;
		
	display_set_gui_size(WIN_SW, WIN_SH);
		
	clearPanel();
	setPanel();
		
	PANEL_GRAPH.fullView();
	PANEL_PREVIEW.fullView();
		
	o_main.alarm[0] = 10;
	PREF_SAVE();
}