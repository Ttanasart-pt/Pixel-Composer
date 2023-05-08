function Panel_Node_Align() : PanelContent() constructor {
	title = "Align";
	w = ui(200);
	h = ui(200);
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var xc = w / 2;
		var yy = 12;
		
		draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text_sub);
		draw_text(xc, yy, "Align");
		
		yy += ui(24);
		if(buttonInstant(THEME.button_hide, xc - ui(16) - ui(40), yy, 32, 32, [mx, my], pFOCUS, pHOVER,, THEME.inspector_surface_halign, 0, c_white) == 2)
			node_halign(PANEL_GRAPH.nodes_select_list, fa_left);
		if(buttonInstant(THEME.button_hide, xc - ui(16),          yy, 32, 32, [mx, my], pFOCUS, pHOVER,, THEME.inspector_surface_halign, 1, c_white) == 2)
			node_halign(PANEL_GRAPH.nodes_select_list, fa_center);
		if(buttonInstant(THEME.button_hide, xc - ui(16) + ui(40), yy, 32, 32, [mx, my], pFOCUS, pHOVER,, THEME.inspector_surface_halign, 2, c_white) == 2)
			node_halign(PANEL_GRAPH.nodes_select_list, fa_right);
		
		yy += ui(40);
		if(buttonInstant(THEME.button_hide, xc - ui(16) - ui(40), yy, 32, 32, [mx, my], pFOCUS, pHOVER,, THEME.inspector_surface_valign, 0, c_white) == 2)
			node_valign(PANEL_GRAPH.nodes_select_list, fa_top);
		if(buttonInstant(THEME.button_hide, xc - ui(16),          yy, 32, 32, [mx, my], pFOCUS, pHOVER,, THEME.inspector_surface_valign, 1, c_white) == 2)
			node_valign(PANEL_GRAPH.nodes_select_list, fa_middle);
		if(buttonInstant(THEME.button_hide, xc - ui(16) + ui(40), yy, 32, 32, [mx, my], pFOCUS, pHOVER,, THEME.inspector_surface_valign, 2, c_white) == 2)
			node_valign(PANEL_GRAPH.nodes_select_list, fa_bottom);
		
		yy += ui(44);
		draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text_sub);
		draw_text(xc, yy, "Distribute");
		
		yy += ui(24);
		if(buttonInstant(THEME.button_hide, xc - ui(16) - ui(20), yy, 32, 32, [mx, my], pFOCUS, pHOVER,, THEME.obj_distribute_h, 0, c_white) == 2)
			node_hdistribute(PANEL_GRAPH.nodes_select_list);
		if(buttonInstant(THEME.button_hide, xc - ui(16) + ui(20), yy, 32, 32, [mx, my], pFOCUS, pHOVER,, THEME.obj_distribute_v, 0, c_white) == 2)
			node_vdistribute(PANEL_GRAPH.nodes_select_list);
	}
}