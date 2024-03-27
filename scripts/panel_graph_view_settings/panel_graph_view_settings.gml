function Panel_Graph_View_Setting(display) : Panel_Linear_Setting() constructor {
	title = __txtx("graph_view_settings", "View Settings");
	
	w = ui(380);
	display_parameter = display;
	
	#region data
		properties = [
			new __Panel_Linear_Setting_Item(
				__txt("Grid"),
				new checkBox(function() { display_parameter.show_grid = !display_parameter.show_grid; }),
				function() { return display_parameter.show_grid },
				function(val) { display_parameter.show_grid = val; },
				true,
			),
			new __Panel_Linear_Setting_Item(
				__txtx("graph_visibility_dim", "Dimension"),
				new checkBox(function() { display_parameter.show_dimension = !display_parameter.show_dimension; }),
				function() { return display_parameter.show_dimension },
				function(val) { display_parameter.show_dimension = val; },
				true,
			),
			new __Panel_Linear_Setting_Item(
				__txtx("graph_visibility_compute", "Compute time"),
				new checkBox(function() { display_parameter.show_compute = !display_parameter.show_compute; }),
				function() { return display_parameter.show_compute },
				function(val) { display_parameter.show_compute = val; },
				true,
			),
			new __Panel_Linear_Setting_Item(
				__txtx("graph_visibility_avoid_label", "Avoid Label"),
				new checkBox(function() { display_parameter.avoid_label = !display_parameter.avoid_label; }),
				function() { return display_parameter.avoid_label },
				function(val) { display_parameter.avoid_label = val; },
				true,
			),
			new __Panel_Linear_Setting_Item(
				__txtx("graph_visibility_preview_scale", "Preview Scale"),
				slider(50, 100, 1, function(val) { display_parameter.preview_scale = val; }),
				function() { return display_parameter.preview_scale },
				function(val) { display_parameter.preview_scale = val; },
				100,
			),
		];
		
		setHeight();
	#endregion
}