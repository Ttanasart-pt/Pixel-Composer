/// @description init
event_inherited();

#region data
	dialog_w = ui(320);
	
	destroy_on_click_out = true;
	preview_panel = noone;
#endregion

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
	
	dialog_h = ui(60 + 40 * array_length(properties));
#endregion