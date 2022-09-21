/// @description init
event_inherited();

#region data
	dialog_w = 280;
	dialog_h = 144;
	
	destroy_on_click_out = true;
#endregion

#region data
	cb_enable = new checkBox(function(str) {
		PANEL_GRAPH.node_drag_snap = !PANEL_GRAPH.node_drag_snap;
	})
	
	tb_size = new textBox(TEXTBOX_INPUT.number, function(str) {
		PANEL_GRAPH.graph_line_s = max(1, real(str));	
	})
#endregion