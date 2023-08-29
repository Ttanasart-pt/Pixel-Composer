function Panel_Graph_View_Setting(display) : Panel_Linear_Setting() constructor {
	title = __txtx("graph_view_settings", "View Settings");
	
	w = ui(380);
	display_parameter = display;
	
	#region data
		properties = [
			[
				new checkBox(function() { display_parameter.show_grid = !display_parameter.show_grid; }),
				__txt("Grid"),
				function() { return display_parameter.show_grid },
			],
			[
				new checkBox(function() { display_parameter.show_dimension = !display_parameter.show_dimension; }),
				__txtx("graph_visibility_dim", "Dimension"),
				function() { return display_parameter.show_dimension },
			],
			[
				new checkBox(function() { display_parameter.show_compute = !display_parameter.show_compute; }),
				__txtx("graph_visibility_compute", "Compute time"),
				function() { return display_parameter.show_compute },
			],
			[
				new checkBox(function() { display_parameter.avoid_label = !display_parameter.avoid_label; }),
				__txtx("graph_visibility_avoid_label", "Avoid Label"),
				function() { return display_parameter.avoid_label },
			],
			[
				new slider(50, 100, 1, function(val) { display_parameter.preview_scale = val; }),
				__txtx("graph_visibility_preview_scale", "Preview Scale"),
				function() { return display_parameter.preview_scale },
			],
		];
		
		setHeight();
	#endregion
}