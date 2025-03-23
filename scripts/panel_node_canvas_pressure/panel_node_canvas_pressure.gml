function Panel_Node_Canvas_Pressure(canvas) : Panel_Linear_Setting() constructor {
	title = __txtx("pen_pressure_settings", "Per Pressure Settings");
	
	w = ui(380);
	self.canvas = canvas;
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txt("Use Pressure"),
			new checkBox(function() /*=>*/ { canvas.tool_attribute.pressure = !canvas.tool_attribute.pressure; }),
			function( ) /*=>*/ {return canvas.tool_attribute.pressure},
			function(v) /*=>*/ { canvas.tool_attribute.pressure = v; },
			false,
		), 
		new __Panel_Linear_Setting_Item(
			__txt("Size"),
			new vectorBox(2, function(v, i) /*=>*/ { canvas.tool_attribute.pressure_size[i] = v; }),
			function( ) /*=>*/ {return canvas.tool_attribute.pressure_size},
			function(v) /*=>*/ { canvas.tool_attribute.pressure_size = v; },
			[ 1, 1 ],
		), 
	];
	
	setHeight();
}