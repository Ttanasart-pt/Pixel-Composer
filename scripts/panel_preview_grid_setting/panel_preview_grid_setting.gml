function Panel_Preview_Grid_Setting() : Panel_Linear_Setting() constructor {
	title = __txtx("preview_grid_settings", "Grid Settings");
	previewGrid = PROJECT.previewGrid;
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txt("Enabled"),
			new checkBox(function() /*=>*/ { previewGrid.show = !previewGrid.show; }),
			function( ) /*=>*/   {return previewGrid.show},
			function(v) /*=>*/ { previewGrid.show = v; },
			PREFERENCES.project_previewGrid.show,
			["Preview", "Toggle Grid"],
			"project_previewGrid.show",
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Pixel Grid"),
			new checkBox(function() /*=>*/ { previewGrid.pixel = !previewGrid.pixel; }),
			function( ) /*=>*/   {return previewGrid.pixel},
			function(v) /*=>*/ { previewGrid.pixel = v; },
			PREFERENCES.project_previewGrid.pixel,
			["Preview", "Toggle Pixel Grid"],
			"project_previewGrid.pixel",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("grid_snap", "Snap to grid"),
			new checkBox(function() /*=>*/ { previewGrid.snap = !previewGrid.snap; }),
			function( ) /*=>*/   {return previewGrid.snap},
			function(v) /*=>*/ { previewGrid.snap = v; },
			PREFERENCES.project_previewGrid.snap,
			["Preview", "Toggle Snap to Grid"],
			"project_previewGrid.snap",
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Grid size"),
			new vectorBox(2, function(value, index) /*=>*/ { var _v = previewGrid.size[index]; previewGrid.size[index] = max(1, value); return _v != max(1, value); })
				.setLinkInactiveColor(COLORS._main_icon_light),
			function( ) /*=>*/   {return previewGrid.size},
			function(v) /*=>*/ { previewGrid.size = v; },
			PREFERENCES.project_previewGrid.size,
			noone,
			"project_previewGrid.size",
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Grid opacity"),
			slider(0, 1, .05, function(str) /*=>*/ { previewGrid.opacity = clamp(real(str), 0, 1);	}),
			function( ) /*=>*/   {return previewGrid.opacity},
			function(v) /*=>*/ { previewGrid.opacity = v; },
			PREFERENCES.project_previewGrid.opacity,
			noone,
			"project_previewGrid.opacity",
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Grid color"),
			new buttonColor(function(color) /*=>*/ { previewGrid.color = color; }, self),
			function( ) /*=>*/   {return previewGrid.color},
			function(v) /*=>*/ { previewGrid.color = v; },
			PREFERENCES.project_previewGrid.color,
			noone,
			"project_previewGrid.color",
		),
		
	];

	setHeight();
}