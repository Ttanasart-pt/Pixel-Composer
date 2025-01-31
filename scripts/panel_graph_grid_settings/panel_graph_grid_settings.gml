function Panel_Graph_Grid_Setting() : Panel_Linear_Setting() constructor {
	title     = __txtx("graph_grid_settings", "Grid Settings");
	project   = PANEL_GRAPH.project;
	graphGrid = project.graphGrid;
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txtx("grid_snap", "Snap to grid"),
			new checkBox(function() /*=>*/ { graphGrid.snap = !graphGrid.snap; }),
			function( ) /*=>*/   {return graphGrid.snap},
			function(v) /*=>*/ { graphGrid.snap = v; },
			PREFERENCES.project_graphGrid.snap,
			["Graph", "Toggle Grid Snap"],
			"project_graphGrid.snap",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("grid_size", "Grid size"),
			new textBox(TEXTBOX_INPUT.number, function(str) /*=>*/ { graphGrid.size = max(1, real(str)); }),
			function( ) /*=>*/   {return graphGrid.size},
			function(v) /*=>*/ { graphGrid.size = v; },
			PREFERENCES.project_graphGrid.size,
			noone,
			"project_graphGrid.size",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("project_graphGrid_opacity", "Grid opacity"),
			slider(0, 1, .05, function(str) /*=>*/ { graphGrid.opacity = clamp(real(str), 0, 1); }),
			function( ) /*=>*/   {return graphGrid.opacity},
			function(v) /*=>*/ { graphGrid.opacity = v; },
			PREFERENCES.project_graphGrid.opacity,
			noone,
			"project_graphGrid.opacity",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("project_graphGrid_color", "Grid color"),
			new buttonColor(function(color) /*=>*/ { graphGrid.color = color; }, self),
			function( ) /*=>*/   {return graphGrid.color},
			function(v) /*=>*/ { graphGrid.color = v; },
			PREFERENCES.project_graphGrid.color,
			noone,
			"project_graphGrid.color",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("grid_show_origin", "Show origin"),
			new checkBox(function() /*=>*/ { graphGrid.show_origin = !graphGrid.show_origin; }),
			function( ) /*=>*/   {return graphGrid.show_origin},
			function(v) /*=>*/ { graphGrid.show_origin = v; },
			PREFERENCES.project_graphGrid.show_origin,
			["Graph", "Toggle Show Origin"],
			"project_graphGrid.show_origin",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("grid_highlight_every", "Highlight period"),
			new textBox(TEXTBOX_INPUT.number, function(str) /*=>*/ { graphGrid.highlight = max(1, round(real(str))); }),
			function( ) /*=>*/   {return graphGrid.highlight},
			function(v) /*=>*/ { graphGrid.highlight = v; },
			PREFERENCES.project_graphGrid.highlight,
			noone,
			"project_graphGrid.highlight",
		),
		
	];
	
	setHeight();
}