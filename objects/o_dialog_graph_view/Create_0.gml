/// @description init
event_inherited();

#region data
	dialog_w = ui(280);
	dialog_h = ui(60 + 40 * 3);
	
	destroy_on_click_out = true;
#endregion

#region data
	cb_grid = new checkBox(function() {
		PANEL_GRAPH.show_grid = !PANEL_GRAPH.show_grid;
	})
	
	cb_dim = new checkBox(function() {
		PANEL_GRAPH.show_dimension = !PANEL_GRAPH.show_dimension;
	})
	
	cb_com = new checkBox(function() {
		PANEL_GRAPH.show_compute = !PANEL_GRAPH.show_compute;
	})
#endregion