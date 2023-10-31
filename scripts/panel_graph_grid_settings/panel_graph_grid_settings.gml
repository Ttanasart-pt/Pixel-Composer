function Panel_Graph_Grid_Setting() : Panel_Linear_Setting() constructor {
	title = __txtx("graph_grid_settings", "Grid Settings");
	
	w = ui(380);
	
	#region data
		properties = [
			new __Panel_Linear_Setting_Item(
				__txtx("grid_snap", "Snap to grid"),
				new checkBox(function() {
					if(PANEL_GRAPH.project == noone || !PANEL_GRAPH.project.active) return;
					PANEL_GRAPH.project.graphGrid.snap = !PANEL_GRAPH.project.graphGrid.snap;
				}),
				function() { return PANEL_GRAPH.project.graphGrid.snap; },
				function(val) { PANEL_GRAPH.project.graphGrid.snap = val; },
				true,
			),
			new __Panel_Linear_Setting_Item(
				__txtx("grid_size", "Grid size"),
				new textBox(TEXTBOX_INPUT.number, function(str) {
					if(PANEL_GRAPH.project == noone || !PANEL_GRAPH.project.active) return;
					PANEL_GRAPH.project.graphGrid.size = max(1, real(str));	
				}),
				function() { return PANEL_GRAPH.project.graphGrid.size; },
				function(val) { PANEL_GRAPH.project.graphGrid.size = val; },
				16,
			),
			new __Panel_Linear_Setting_Item(
				__txtx("project_graphGrid_opacity", "Grid opacity"),
				new slider(0, 1, .05, function(str) {
					if(PANEL_GRAPH.project == noone || !PANEL_GRAPH.project.active) return;
					PANEL_GRAPH.project.graphGrid.opacity = clamp(real(str), 0, 1);	
				}),
				function() { return PANEL_GRAPH.project.graphGrid.opacity; },
				function(val) { PANEL_GRAPH.project.graphGrid.opacity = val; },
				0.05,
			),
			new __Panel_Linear_Setting_Item(
				__txtx("project_graphGrid_color", "Grid color"),
				new buttonColor(function(color) {
					if(PANEL_GRAPH.project == noone || !PANEL_GRAPH.project.active) return;
					PANEL_GRAPH.project.graphGrid.color = color;
				}, self),
				function() { return PANEL_GRAPH.project.graphGrid.color; },
				function(val) { PANEL_GRAPH.project.graphGrid.color = val; },
				c_white,
			),
			new __Panel_Linear_Setting_Item(
				__txtx("grid_show_origin", "Show origin"),
				new checkBox(function() {
					if(PANEL_GRAPH.project == noone || !PANEL_GRAPH.project.active) return;
					PANEL_GRAPH.project.graphGrid.show_origin = !PANEL_GRAPH.project.graphGrid.show_origin;
				}),
				function() { return PANEL_GRAPH.project.graphGrid.show_origin; },
				function(val) { PANEL_GRAPH.project.graphGrid.show_origin = val; },
				false,
			),
			new __Panel_Linear_Setting_Item(
				__txtx("grid_highlight_every", "Highlight period"),
				new textBox(TEXTBOX_INPUT.number, function(str) {
					if(PANEL_GRAPH.project == noone || !PANEL_GRAPH.project.active) return;
					PANEL_GRAPH.project.graphGrid.highlight = max(1, round(real(str)));	
				}),
				function() { return PANEL_GRAPH.project.graphGrid.highlight; },
				function(val) { PANEL_GRAPH.project.graphGrid.highlight = val; },
				12,
			),
			
		];
		
		setHeight();
	#endregion
}