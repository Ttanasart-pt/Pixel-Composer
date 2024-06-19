function Panel_Node_Canvas_Pressure(canvas) : Panel_Linear_Setting() constructor {
	title = __txtx("pen_pressure_settings", "Per Pressure Settings");
	
	w = ui(380);
	self.canvas = canvas;
	
	#region data
		properties = [
			new __Panel_Linear_Setting_Item(
				__txt("Pressure"),
				new checkBox(function() { canvas.tool_attribute.pressure = !canvas.tool_attribute.pressure; }),
				function() { return canvas.tool_attribute.pressure; },
				function(val) { canvas.tool_attribute.pressure = val; },
				false,
			), 
			new __Panel_Linear_Setting_Item(
				__txt("Size"),
				new vectorBox(2, function(value, index) { canvas.tool_attribute.pressure_size[index] = value; }),
				function() { return canvas.tool_attribute.pressure_size; },
				function(val) { canvas.tool_attribute.pressure_size = val; },
				[ 1, 1 ],
			), 
		];
		
		setHeight();
	#endregion
}