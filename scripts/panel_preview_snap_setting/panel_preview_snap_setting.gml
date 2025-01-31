function Panel_Preview_Snap_Setting() : Panel_Linear_Setting() constructor {
	title = __txtx("preview_snap_settings", "3D Snap Settings");
	previewPanel = PROJECT.previewSetting;
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txt("Snap"),
			new checkBox(function() /*=>*/ { previewPanel.d3_tool_snap = !previewPanel.d3_tool_snap; }),
			function( ) /*=>*/   {return previewPanel.d3_tool_snap},
			function(v) /*=>*/ { previewPanel.d3_tool_snap = v; },
			PREFERENCES.project_previewSetting.d3_tool_snap,
			noone,
			"project_previewSetting.d3_tool_snap",
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Linear"),
			new textBox(TEXTBOX_INPUT.number, function(v) /*=>*/ { previewPanel.d3_tool_snap_position = v; }),
			function( ) /*=>*/   {return previewPanel.d3_tool_snap_position},
			function(v) /*=>*/ { previewPanel.d3_tool_snap_position = v; },
			PREFERENCES.project_previewSetting.d3_tool_snap_position,
			noone,
			"project_previewSetting.d3_tool_snap_position",
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Rotation"),
			new textBox(TEXTBOX_INPUT.number, function(v) /*=>*/ { previewPanel.d3_tool_snap_rotation = v; }),
			function( ) /*=>*/   {return previewPanel.d3_tool_snap_rotation},
			function(v) /*=>*/ { previewPanel.d3_tool_snap_rotation = v; },
			PREFERENCES.project_previewSetting.d3_tool_snap_rotation,
			noone,
			"project_previewSetting.d3_tool_snap_rotation",
		),
	]

	setHeight();
}