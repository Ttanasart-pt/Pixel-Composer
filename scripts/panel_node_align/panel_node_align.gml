function Panel_Node_Align() : PanelContent() constructor {
	title = __txt("Align");
	w = 160;
	h = 32 + 8 * 2;
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var xx = 8;
		var yy = 8;
		
		/////////////////////////////
		
		if(buttonInstant(THEME.button_hide, xx, yy, 32, 32, [mx, my], pFOCUS, pHOVER,, THEME.object_halign, 0, c_white) == 2)
			node_halign(PANEL_GRAPH.nodes_selecting, fa_left);
		xx += 34
		
		if(buttonInstant(THEME.button_hide, xx, yy, 32, 32, [mx, my], pFOCUS, pHOVER,, THEME.object_halign, 1, c_white) == 2)
			node_halign(PANEL_GRAPH.nodes_selecting, fa_center);
		xx += 34
			
		if(buttonInstant(THEME.button_hide, xx, yy, 32, 32, [mx, my], pFOCUS, pHOVER,, THEME.object_halign, 2, c_white) == 2)
			node_halign(PANEL_GRAPH.nodes_selecting, fa_right);
		xx += 34
		
		xx += 2;
		draw_set_color(CDEF.main_dkblack);
		draw_line_width(xx, yy + 16 - 10, xx, yy + 16 + 10, 3);
		xx += 6;
		
		/////////////////////////////
		
		if(buttonInstant(THEME.button_hide, xx, yy, 32, 32, [mx, my], pFOCUS, pHOVER,, THEME.object_valign, 0, c_white) == 2)
			node_valign(PANEL_GRAPH.nodes_selecting, fa_top);
		xx += 34
		
		if(buttonInstant(THEME.button_hide, xx, yy, 32, 32, [mx, my], pFOCUS, pHOVER,, THEME.object_valign, 1, c_white) == 2)
			node_valign(PANEL_GRAPH.nodes_selecting, fa_middle);
		xx += 34
		
		if(buttonInstant(THEME.button_hide, xx, yy, 32, 32, [mx, my], pFOCUS, pHOVER,, THEME.object_valign, 2, c_white) == 2)
			node_valign(PANEL_GRAPH.nodes_selecting, fa_bottom);
		xx += 34
		
		xx += 2;
		draw_set_color(CDEF.main_dkblack);
		draw_line_width(xx, yy + 16 - 10, xx, yy + 16 + 10, 3);
		xx += 6;
		
		/////////////////////////////
		
		if(buttonInstant(THEME.button_hide, xx, yy, 32, 32, [mx, my], pFOCUS, pHOVER,, THEME.obj_distribute_h, 0, c_white) == 2)
			node_hdistribute(PANEL_GRAPH.nodes_selecting);
		xx += 34
		
		if(buttonInstant(THEME.button_hide, xx, yy, 32, 32, [mx, my], pFOCUS, pHOVER,, THEME.obj_distribute_v, 0, c_white) == 2)
			node_vdistribute(PANEL_GRAPH.nodes_selecting);
		xx += 34
	}
}