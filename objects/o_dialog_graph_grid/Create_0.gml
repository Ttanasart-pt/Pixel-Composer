/// @description init
event_inherited();

#region data
	dialog_w = ui(320);
	dialog_h = ui(220);
	
	destroy_on_click_out = true;
#endregion

#region data
	cb_enable = new checkBox(function(str) {
		if(PANEL_GRAPH.project == noone || !PANEL_GRAPH.project.active) return;
		PANEL_GRAPH.project.graphGrid.snap = !PANEL_GRAPH.project.graphGrid.snap;
	})
	
	tb_size = new textBox(TEXTBOX_INPUT.number, function(str) {
		if(PANEL_GRAPH.project == noone || !PANEL_GRAPH.project.active) return;
		PANEL_GRAPH.project.graphGrid.size = max(1, real(str));	
	})
	
	sl_opacity = new slider(0, 1, .05, function(str) {
		if(PANEL_GRAPH.project == noone || !PANEL_GRAPH.project.active) return;
		PANEL_GRAPH.project.graphGrid.opacity = clamp(real(str), 0, 1);	
	})
	
	cl_color = new buttonColor(function(color) {
		if(PANEL_GRAPH.project == noone || !PANEL_GRAPH.project.active) return;
		PANEL_GRAPH.project.graphGrid.color = color;
	}, self);
#endregion