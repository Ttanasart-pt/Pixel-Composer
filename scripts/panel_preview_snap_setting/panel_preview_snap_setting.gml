function Panel_Preview_Snap_Setting(panel) : Panel_Linear_Setting() constructor {
	title = __txtx("preview_snap_settings", "3D Snap Settings");
	
	w = ui(380);
	preview_panel = panel;
	
	#region data
		properties = [
			[
				new checkBox(function() { preview_panel.d3_tool_snap = !preview_panel.d3_tool_snap; }),
				__txt("Snap"),
				function() { return preview_panel.d3_tool_snap },
			],
			[
				new textBox(TEXTBOX_INPUT.number, function(val) { preview_panel.d3_tool_snap_position = val; }),
				__txt("Linear"),
				function() { return preview_panel.d3_tool_snap_position },
			],
			[
				new textBox(TEXTBOX_INPUT.number, function(val) { preview_panel.d3_tool_snap_rotation = val; }),
				__txt("Rotation"),
				function() { return preview_panel.d3_tool_snap_rotation },
			],
		]
	
		setHeight();
	#endregion
}