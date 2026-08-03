function Panel_Canvas_Grid_Setting(_canvas) : Panel_Linear_Setting() constructor {
	title  = __txt("preview_grid_settings", "Grid Settings");
	canvas = _canvas;
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txt("Enabled"),
			new checkBox(function() /*=>*/ { canvas.grid_show = !canvas.grid_show; }),
			function( ) /*=>*/   {return canvas.grid_show},
			function(v) /*=>*/ { canvas.grid_show = v; }
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Size"),
			textBox_Number(function(g) /*=>*/ { canvas.grid_size = g; }),
			function( ) /*=>*/   {return canvas.grid_size},
			function(v) /*=>*/ { canvas.grid_size = v; },
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Grid Color"),
			new buttonColor(function(color) /*=>*/ { canvas.grid_color = color; }, self),
			function( ) /*=>*/   {return canvas.grid_color},
			function(v) /*=>*/ { canvas.grid_color = v; },
		),
		
		-1,
		
		new __Panel_Linear_Setting_Item(
			__txt("Pixel Grid"),
			new checkBox(function() /*=>*/ { canvas.grid_pixel = !canvas.grid_pixel; }),
			function( ) /*=>*/   {return canvas.grid_pixel},
			function(v) /*=>*/ { canvas.grid_pixel = v; }
		),
		
	];

	setHeight();
}