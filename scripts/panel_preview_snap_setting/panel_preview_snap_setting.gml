function Panel_Preview_Snap_Setting(panel) : Panel_Linear_Setting() constructor {
	title = __txtx("preview_snap_settings", "3D Snap Settings");
	
	w = ui(380);
	preview_panel = panel;
	
	#region data
		properties = [
			new __Panel_Linear_Setting_Item(
				__txt("Snap"),
				new checkBox(function() { preview_panel.d3_tool_snap = !preview_panel.d3_tool_snap; }),
				function() { return preview_panel.d3_tool_snap },
				function(val) { preview_panel.d3_tool_snap = val; },
				false,
			),
			new __Panel_Linear_Setting_Item(
				__txt("Linear"),
				new textBox(TEXTBOX_INPUT.number, function(val) { preview_panel.d3_tool_snap_position = val; }),
				function() { return preview_panel.d3_tool_snap_position },
				function(val) { preview_panel.d3_tool_snap_position = val; },
				1,
			),
			new __Panel_Linear_Setting_Item(
				__txt("Rotation"),
				new textBox(TEXTBOX_INPUT.number, function(val) { preview_panel.d3_tool_snap_rotation = val; }),
				function() { return preview_panel.d3_tool_snap_rotation },
				function(val) { preview_panel.d3_tool_snap_rotation = val; },
				15,
			),
		]
	
		setHeight();
	#endregion
}