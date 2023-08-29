function Panel_Graph_Grid_Setting() : Panel_Linear_Setting() constructor {
	title = __txtx("graph_grid_settings", "Grid Settings");
	
	w = ui(380);
	
	#region data
		properties = [
			[
				new checkBox(function(str) {
					if(PANEL_GRAPH.project == noone || !PANEL_GRAPH.project.active) return;
					PANEL_GRAPH.project.graphGrid.snap = !PANEL_GRAPH.project.graphGrid.snap;
				}),
				__txtx("grid_snap", "Snap to grid"),
				function() { return PANEL_GRAPH.project.graphGrid.snap; }
			],
			[
				new textBox(TEXTBOX_INPUT.number, function(str) {
					if(PANEL_GRAPH.project == noone || !PANEL_GRAPH.project.active) return;
					PANEL_GRAPH.project.graphGrid.size = max(1, real(str));	
				}),
				__txtx("grid_size", "Grid size"),
				function() { return PANEL_GRAPH.project.graphGrid.size; }
			],
			[
				new slider(0, 1, .05, function(str) {
					if(PANEL_GRAPH.project == noone || !PANEL_GRAPH.project.active) return;
					PANEL_GRAPH.project.graphGrid.opacity = clamp(real(str), 0, 1);	
				}),
				__txtx("project.graphGrid.opacity", "Grid opacity"),
				function() { return PANEL_GRAPH.project.graphGrid.opacity; }
			],
			[
				new buttonColor(function(color) {
					if(PANEL_GRAPH.project == noone || !PANEL_GRAPH.project.active) return;
					PANEL_GRAPH.project.graphGrid.color = color;
				}, self),
				__txtx("project.graphGrid.color", "Grid color"),
				function() { return PANEL_GRAPH.project.graphGrid.color; }
			]
		];
		
		setHeight();
	#endregion
}