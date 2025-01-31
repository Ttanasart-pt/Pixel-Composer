function Panel_Graph_View_Setting(graphPanel, display) : Panel_Linear_Setting() constructor {
	title = __txtx("graph_view_settings", "View Settings");
	
	self.graphPanel   = graphPanel;
	display_parameter = display;
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txt("Grid"),
			new checkBox(function() /*=>*/ { display_parameter.show_grid = !display_parameter.show_grid; }),
			function()    /*=>*/   {return display_parameter.show_grid},
			function(val) /*=>*/ { display_parameter.show_grid = val; },
			PREFERENCES.project_graphDisplay.show_grid,
			[ "Graph", "Toggle Grid" ],
			"project_graphDisplay.show_grid",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("graph_visibility_dim", "Dimension"),
			new checkBox(function() /*=>*/ { display_parameter.show_dimension = !display_parameter.show_dimension; }),
			function()    /*=>*/   {return display_parameter.show_dimension},
			function(val) /*=>*/ { display_parameter.show_dimension = val; },
			PREFERENCES.project_graphDisplay.show_dimension,
			[ "Graph", "Toggle Dimension" ],
			"project_graphDisplay.show_dimension",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("graph_visibility_compute", "Compute Time"),
			new checkBox(function() /*=>*/ { display_parameter.show_compute = !display_parameter.show_compute; }),
			function()    /*=>*/   {return display_parameter.show_compute},
			function(val) /*=>*/ { display_parameter.show_compute = val; },
			PREFERENCES.project_graphDisplay.show_compute,
			[ "Graph", "Toggle Compute" ],
			"project_graphDisplay.show_compute",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("graph_visibility_avoid_label", "Avoid Label"),
			new checkBox(function() /*=>*/ { display_parameter.avoid_label = !display_parameter.avoid_label; }),
			function()    /*=>*/   {return display_parameter.avoid_label},
			function(val) /*=>*/ { display_parameter.avoid_label = val; },
			PREFERENCES.project_graphDisplay.avoid_label,
			[ "Graph", "Toggle Avoid Label" ],
			"project_graphDisplay.avoid_label",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("graph_visibility_slideshow", "Show Controller"),
			new checkBox(function() /*=>*/ { display_parameter.show_control = !display_parameter.show_control; }),
			function()    /*=>*/   {return display_parameter.show_control},
			function(val) /*=>*/ { display_parameter.show_control = val; },
			PREFERENCES.project_graphDisplay.show_control,
			[ "Graph", "Toggle Control" ],
			"project_graphDisplay.show_control",
		),
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		new __Panel_Linear_Setting_Item(
			__txtx("graph_visibility_preview_scale", "Preview Scale"),
			slider(50, 100, 1, function(val) /*=>*/ { display_parameter.preview_scale = val; }),
			function()    /*=>*/   {return display_parameter.preview_scale},
			function(val) /*=>*/ { display_parameter.preview_scale = val; },
			PREFERENCES.project_graphDisplay.preview_scale,
			noone,
			"project_graphDisplay.preview_scale",
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("View Control"),
			new buttonGroup([ "None", "Left", "Right" ], function(val) /*=>*/ { display_parameter.show_view_control = val; }),
			function()    /*=>*/   {return display_parameter.show_view_control},
			function(val) /*=>*/ { display_parameter.show_view_control = val; },
			PREFERENCES.project_graphDisplay.show_view_control,
			noone,
			"project_graphDisplay.show_view_control",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("graph_visibility_tooltip", "Show Tooltip"),
			new checkBox(function() /*=>*/ { display_parameter.show_tooltip = !display_parameter.show_tooltip; }),
			function()    /*=>*/   {return display_parameter.show_tooltip},
			function(val) /*=>*/ { display_parameter.show_tooltip = val; },
			PREFERENCES.project_graphDisplay.show_tooltip,
			[ "Graph", "Toggle Tooltip" ],
			"project_graphDisplay.show_tooltip",
		),
	];
	
	setHeight();
}