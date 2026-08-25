globalvar CLICK_REFRESH; CLICK_REFRESH = false;

function window_refresh() {
	o_main.win_wp = WIN_W;
	o_main.win_hp = WIN_H;	
	room_width    = WIN_W;
	room_height   = WIN_H;
		
	display_set_gui_size(WIN_SW, WIN_SH);
}

function display_refresh() {
	window_refresh();
	refreshPanel();
		
	if(PANEL_GRAPH)   PANEL_GRAPH.fullView();
	if(PANEL_PREVIEW) PANEL_PREVIEW.fullView();
		
	run_in(10, Render);
	PREF_SAVE();
}

// double display size for retina display

#macro display_get_width display_get_width_os
#macro __display_get_width display_get_width
function display_get_width_os() { return os_type == os_macosx? __display_get_width() * 2 : __display_get_width(); }

#macro display_get_height display_get_height_os
#macro __display_get_height display_get_height
function display_get_height_os() { return os_type == os_macosx? __display_get_height() * 2 : __display_get_height(); }
