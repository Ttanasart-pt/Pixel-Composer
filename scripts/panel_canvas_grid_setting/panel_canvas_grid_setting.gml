function Panel_Canvas_Grid_Setting(_canvas) : Panel_Linear_Setting() constructor {
	title      = __txt("preview_grid_settings", "Grid Settings");
	canvas     = _canvas;
	node       = canvas.node;
	attributes = node.attributes;
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txt("Enabled"),
			new checkBox(function() /*=>*/ { attributes.grid_show = !attributes.grid_show; }),
			function( ) /*=>*/   {return attributes.grid_show},
			function(v) /*=>*/ { attributes.grid_show = v; }
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Size"),
			textBox_Number(function(g) /*=>*/ { attributes.grid_size = g; }),
			function( ) /*=>*/   {return attributes.grid_size},
			function(v) /*=>*/ { attributes.grid_size = v; },
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Grid Color"),
			new buttonColor(function(color) /*=>*/ { attributes.grid_color = color; }, self),
			function( ) /*=>*/   {return attributes.grid_color},
			function(v) /*=>*/ { attributes.grid_color = v; },
		),
		
		-1,
		
		new __Panel_Linear_Setting_Item(
			__txt("Pixel Grid"),
			new checkBox(function() /*=>*/ { attributes.grid_pixel = !attributes.grid_pixel; }),
			function( ) /*=>*/   {return attributes.grid_pixel},
			function(v) /*=>*/ { attributes.grid_pixel = v; }
		),
		
	];

	setHeight();
}