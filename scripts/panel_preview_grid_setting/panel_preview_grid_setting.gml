function Panel_Preview_Grid_Setting() : Panel_Linear_Setting() constructor {
	title = __txtx("preview_grid_settings", "Grid Settings");
	
	w = ui(380);
	
	#region data
		properties = [
			new __Panel_Linear_Setting_Item(
				__txt("Pixel Grid"),
				new checkBox(function() { PROJECT.previewGrid.pixel = !PROJECT.previewGrid.pixel; }),
				function() { return PROJECT.previewGrid.pixel; },
				function(val) { PROJECT.previewGrid.pixel = val; },
				false,
			),
			new __Panel_Linear_Setting_Item(
				__txt("Enabled"),
				new checkBox(function() { PROJECT.previewGrid.show = !PROJECT.previewGrid.show; }),
				function() { return PROJECT.previewGrid.show; },
				function(val) { PROJECT.previewGrid.show = val; },
				false,
			),
			new __Panel_Linear_Setting_Item(
				__txtx("grid_snap", "Snap to grid"),
				new checkBox(function() { PROJECT.previewGrid.snap = !PROJECT.previewGrid.snap; }),
				function() { return PROJECT.previewGrid.snap; },
				function(val) { PROJECT.previewGrid.snap = val; },
				false,
			),
			new __Panel_Linear_Setting_Item(
				__txt("Grid size"),
				new vectorBox(2, function(value, index) {
					var _v = PROJECT.previewGrid.size[index];
					PROJECT.previewGrid.size[index] = max(1, value);
					
					return _v != max(1, value);
				}).setLinkInactiveColor(COLORS._main_icon_light),
				function() { return PROJECT.previewGrid.size; },
				function(val) { PROJECT.previewGrid.size = val; },
				[ 16, 16 ],
			),
			new __Panel_Linear_Setting_Item(
				__txt("Grid opacity"),
				slider(0, 1, .05, function(str) { PROJECT.previewGrid.opacity = clamp(real(str), 0, 1);	}),
				function() { return PROJECT.previewGrid.opacity; },
				function(val) { PROJECT.previewGrid.opacity = val; },
				0.5,
			),
			new __Panel_Linear_Setting_Item(
				__txt("Grid color"),
				new buttonColor(function(color) { PROJECT.previewGrid.color = color; }, self),
				function() { return PROJECT.previewGrid.color; },
				function(val) { PROJECT.previewGrid.color = val; },
				COLORS.panel_preview_grid,
			),
		];
	
		setHeight();
	#endregion
}