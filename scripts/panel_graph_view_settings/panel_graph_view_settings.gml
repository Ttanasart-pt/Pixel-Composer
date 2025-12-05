function Panel_Graph_View_Setting(_graphPanel, _display) : Panel_Linear_Setting() constructor {
	title = __txtx("graph_view_settings", "View Settings");
	
	graphP = _graphPanel;
	dparam = _display;
	
	function refreshDraw() { graphP.refreshDraw(); }
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txt("Grid"),
			new checkBox(function() /*=>*/ { dparam.show_grid = !dparam.show_grid; graphP.refreshDraw(); }),
			function()    /*=>*/   {return dparam.show_grid},
			function(val) /*=>*/ { dparam.show_grid = val; },
			PREFERENCES.project_graphDisplay.show_grid,
			[ "Graph", "Toggle Grid" ],
			"project_graphDisplay.show_grid",
		),
		
		-1, ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		new __Panel_Linear_Setting_Item(
			__txt("Meta View"),
			new buttonGroup(__txts([ "Center", "Compact" ]), function(val) /*=>*/ { dparam.node_meta_view = val; graphP.refreshDraw(); }),
			function()    /*=>*/   {return dparam.node_meta_view},
			function(val) /*=>*/ { dparam.node_meta_view = val; },
			PREFERENCES.project_graphDisplay.node_meta_view,
			[ "Graph", "Toggle Meta View" ],
			"project_graphDisplay.node_meta_view",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("graph_visibility_dim", "Dimension"),
			new checkBox(function() /*=>*/ { dparam.show_dimension = !dparam.show_dimension; graphP.refreshDraw(); }),
			function()    /*=>*/   {return dparam.show_dimension},
			function(val) /*=>*/ { dparam.show_dimension = val; },
			PREFERENCES.project_graphDisplay.show_dimension,
			[ "Graph", "Toggle Dimension" ],
			"project_graphDisplay.show_dimension",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("graph_visibility_compute", "Compute Time"),
			new checkBox(function() /*=>*/ { dparam.show_compute = !dparam.show_compute; graphP.refreshDraw(); }),
			function()    /*=>*/   {return dparam.show_compute},
			function(val) /*=>*/ { dparam.show_compute = val; },
			PREFERENCES.project_graphDisplay.show_compute,
			[ "Graph", "Toggle Compute" ],
			"project_graphDisplay.show_compute",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("graph_visibility_avoid_label", "Avoid Label"),
			new checkBox(function() /*=>*/ { dparam.avoid_label = !dparam.avoid_label; graphP.refreshDraw(); }),
			function()    /*=>*/   {return dparam.avoid_label},
			function(val) /*=>*/ { dparam.avoid_label = val; },
			PREFERENCES.project_graphDisplay.avoid_label,
			[ "Graph", "Toggle Avoid Label" ],
			"project_graphDisplay.avoid_label",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("graph_visibility_slideshow", "Show Controller"),
			new checkBox(function() /*=>*/ { dparam.show_control = !dparam.show_control; graphP.refreshDraw(); }),
			function()    /*=>*/   {return dparam.show_control},
			function(val) /*=>*/ { dparam.show_control = val; },
			PREFERENCES.project_graphDisplay.show_control,
			[ "Graph", "Toggle Control" ],
			"project_graphDisplay.show_control",
		),
		
		-1, ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		new __Panel_Linear_Setting_Item(
			__txtx("graph_visibility_preview_scale", "Preview Scale"),
			slider(50, 100, 1, function(val) /*=>*/ { dparam.preview_scale = val; graphP.refreshDraw(); }),
			function()    /*=>*/   {return dparam.preview_scale},
			function(val) /*=>*/ { dparam.preview_scale = val; },
			PREFERENCES.project_graphDisplay.preview_scale,
			noone,
			"project_graphDisplay.preview_scale",
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("View Control"),
			new buttonGroup(__txts([ "None", "Left", "Right" ]), function(val) /*=>*/ { dparam.show_view_control = val; graphP.refreshDraw(); }),
			function()    /*=>*/   {return dparam.show_view_control},
			function(val) /*=>*/ { dparam.show_view_control = val; },
			PREFERENCES.project_graphDisplay.show_view_control,
			noone,
			"project_graphDisplay.show_view_control",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("graph_visibility_tooltip", "Show Tooltip"),
			new checkBox(function() /*=>*/ { dparam.show_tooltip = !dparam.show_tooltip; graphP.refreshDraw(); }),
			function()    /*=>*/   {return dparam.show_tooltip},
			function(val) /*=>*/ { dparam.show_tooltip = val; },
			PREFERENCES.project_graphDisplay.show_tooltip,
			[ "Graph", "Toggle Tooltip" ],
			"project_graphDisplay.show_tooltip",
		),
	];
	
	setHeight();
}