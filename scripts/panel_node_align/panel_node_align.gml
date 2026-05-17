function Panel_Node_Align() : PanelContent() constructor {
	title = __txt("Align");
	bs = ui(24);
	w  = ui(16) + (bs + ui(2)) * 8 + ui(16);
	h  = bs + ui(8 * 2);
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var m  = [mx,my];
		var xx = ui(8);
		var yy = ui(8);
		var bb = THEME.button_hide_fill;
		
		/////////////////////////////
		
		if(buttonInstant(bb, xx, yy, bs, bs, m, pHOVER, pFOCUS, "", THEME.object_halign, 0, c_white, 1, .75) == 2)
			node_halign(PANEL_GRAPH.nodes_selecting, fa_left);
		xx += bs + ui(2);
		
		if(buttonInstant(bb, xx, yy, bs, bs, m, pHOVER, pFOCUS, "", THEME.object_halign, 1, c_white, 1, .75) == 2)
			node_halign(PANEL_GRAPH.nodes_selecting, fa_center);
		xx += bs + ui(2);
			
		if(buttonInstant(bb, xx, yy, bs, bs, m, pHOVER, pFOCUS, "", THEME.object_halign, 2, c_white, 1, .75) == 2)
			node_halign(PANEL_GRAPH.nodes_selecting, fa_right);
		xx += bs + ui(2);
		
		xx += ui(2);
		draw_set_color(CDEF.main_dkblack);
		draw_line_width(xx, yy + ui(16 - 10), xx, yy + ui(16 + 10), ui(2));
		xx += ui(6);
		
		/////////////////////////////
		
		if(buttonInstant(bb, xx, yy, bs, bs, m, pHOVER, pFOCUS, "", THEME.object_valign, 0, c_white, 1, .75) == 2)
			node_valign(PANEL_GRAPH.nodes_selecting, fa_top);
		xx += bs + ui(2);
		
		if(buttonInstant(bb, xx, yy, bs, bs, m, pHOVER, pFOCUS, "", THEME.object_valign, 1, c_white, 1, .75) == 2)
			node_valign(PANEL_GRAPH.nodes_selecting, fa_middle);
		xx += bs + ui(2);
		
		if(buttonInstant(bb, xx, yy, bs, bs, m, pHOVER, pFOCUS, "", THEME.object_valign, 2, c_white, 1, .75) == 2)
			node_valign(PANEL_GRAPH.nodes_selecting, fa_bottom);
		xx += bs + ui(2);
		
		xx += ui(2);
		draw_set_color(CDEF.main_dkblack);
		draw_line_width(xx, yy + ui(16 - 10), xx, yy + ui(16 + 10), ui(2));
		xx += ui(6);
		
		/////////////////////////////
		
		if(buttonInstant(bb, xx, yy, bs, bs, m, pHOVER, pFOCUS, "", THEME.obj_distribute_h, 0, c_white, 1, .75) == 2)
			node_hdistribute(PANEL_GRAPH.nodes_selecting);
		xx += bs + ui(2);
		
		if(buttonInstant(bb, xx, yy, bs, bs, m, pHOVER, pFOCUS, "", THEME.obj_distribute_v, 0, c_white, 1, .75) == 2)
			node_vdistribute(PANEL_GRAPH.nodes_selecting);
		xx += bs + ui(2);
	}
}