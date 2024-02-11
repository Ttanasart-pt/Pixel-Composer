function window_refresh() {
	o_main.win_wp = WIN_W;
	o_main.win_hp = WIN_H;	
	room_width    = WIN_W;
	room_height   = WIN_H;
		
	display_set_gui_size(WIN_SW, WIN_SH);
}

function display_refresh() {
	window_refresh();
		
	clearPanel();
	resetPanel();
		
	PANEL_GRAPH.fullView();
	PANEL_PREVIEW.fullView();
		
	run_in(10, Render);
	PREF_SAVE();
}