/// @description init
event_inherited();

#region data
	dialog_w = ui(320);
	dialog_h = ui(220);
	
	destroy_on_click_out = true;
#endregion

#region data
	cb_enable = new checkBox(function(str) {
		PANEL_GRAPH.node_drag_snap = !PANEL_GRAPH.node_drag_snap;
	})
	
	tb_size = new textBox(TEXTBOX_INPUT.number, function(str) {
		PANEL_GRAPH.graph_line_s = max(1, real(str));	
	})
	
	sl_opacity = new slider(0, 1, .05, function(str) {
		PANEL_GRAPH.grid_opacity = clamp(real(str), 0, 1);	
	})
	
	cl_color = buttonColor(function(color) {
		PANEL_GRAPH.grid_color = color;
	});
#endregion