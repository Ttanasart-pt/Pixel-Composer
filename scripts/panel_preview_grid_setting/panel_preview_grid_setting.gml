function Panel_Preview_Grid_Setting() : Panel_Linear_Setting() constructor {
	title = __txtx("preview_grid_settings", "Grid Settings");
	
	w = ui(380);
	
	#region data
		properties = [
			[
				new checkBox(function() {
					PROJECT.previewGrid.show = !PROJECT.previewGrid.show;
				}),
				__txt("Enabled"),
				function() { return PROJECT.previewGrid.show; }
			],
			[
				new checkBox(function() {
					PROJECT.previewGrid.snap = !PROJECT.previewGrid.snap;
				}),
				__txtx("grid_snap", "Snap to grid"),
				function() { return PROJECT.previewGrid.snap; }
			],
			[
				new vectorBox(2, function(index, value) {
					var _v = PROJECT.previewGrid.size[index];
					PROJECT.previewGrid.size[index] = max(1, value);
					
					return _v != max(1, value);
				}).setLinkInactiveColor(COLORS._main_icon_light),
				__txt("Grid size"),
				function() { return PROJECT.previewGrid.size; }
			],
			[
				new slider(0, 1, .05, function(str) {
					PROJECT.previewGrid.opacity = clamp(real(str), 0, 1);	
				}),
				__txt("Grid opacity"),
				function() { return PROJECT.previewGrid.opacity; }
			],
			[
				new buttonColor(function(color) {
					PROJECT.previewGrid.color = color;
				}, self),
				__txt("Grid color"),
				function() { return PROJECT.previewGrid.color; }
			]
		];
	
		setHeight();
	#endregion
}