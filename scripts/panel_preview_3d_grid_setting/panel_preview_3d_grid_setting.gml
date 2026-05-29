function Panel_Preview_3D_Grid_Setting() : Panel_Linear_Setting() constructor {
	title   = __txt("preview_3d_grid_settings", "3D Grid Settings");
	previewGrid = PROJECT.previewGrid;
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txt("Enabled"),
			new checkBox(function() /*=>*/ { previewGrid.d3_show = !previewGrid.d3_show; }),
			function( ) /*=>*/   {return previewGrid.d3_show},
			function(v) /*=>*/ { previewGrid.d3_show = v; },
			PREFERENCES.project_previewGrid.d3_show,
			["Preview", "Toggle 3D Grid"],
			"project_previewGrid.d3_show",
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Grid size"),
			textBox_Number(function(v) /*=>*/ { previewGrid.d3_scale = v; }),
			function( ) /*=>*/   {return previewGrid.d3_scale},
			function(v) /*=>*/ { previewGrid.d3_scale = v; },
			PREFERENCES.project_previewGrid.d3_scale,
			noone,
			"project_previewGrid.d3_scale",
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Grid opacity"),
			slider(0, 1, .05, function(str) /*=>*/ { previewGrid.d3_opacity = clamp(real(str), 0, 1);	}),
			function( ) /*=>*/   {return previewGrid.d3_opacity},
			function(v) /*=>*/ { previewGrid.d3_opacity = v; },
			PREFERENCES.project_previewGrid.d3_opacity,
			noone,
			"project_previewGrid.d3_opacity",
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Grid color"),
			new buttonColor(function(color) /*=>*/ { previewGrid.d3_color = color; }, self).hideAlpha(),
			function( ) /*=>*/   {return previewGrid.d3_color},
			function(v) /*=>*/ { previewGrid.d3_color = v; },
			PREFERENCES.project_previewGrid.d3_color,
			noone,
			"project_previewGrid.d3_color",
		),
		
	]
	
	setHeight();
}