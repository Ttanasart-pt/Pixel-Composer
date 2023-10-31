function Panel_Graph_Connection_Setting() : Panel_Linear_Setting() constructor {
	title = __txtx("graph_connection_settings", "Connection Settings");
	
	w = ui(400);
	
	#region data
		properties = [
			[
				new buttonGroup([ THEME.icon_curve_connection, THEME.icon_curve_connection, THEME.icon_curve_connection, THEME.icon_curve_connection ], 
				function(val) { PREFERENCES.curve_connection_line = val; }),
				__txt("Type"),
				function() { return PREFERENCES.curve_connection_line; }
			],
			[
				new textBox(TEXTBOX_INPUT.number, function(str) {
					PREFERENCES.connection_line_width = max(0.5, real(str));
				}),
				__txtx("dialog_connection_thickness", "Line thickness"),
				function() { return PREFERENCES.connection_line_width; }
			],
			[
				new textBox(TEXTBOX_INPUT.number, function(str) {
					PREFERENCES.connection_line_corner = max(0, real(str));
				}).setSlidable(),
				__txtx("dialog_connection_radius", "Corner radius"),
				function() { return PREFERENCES.connection_line_corner; }
			],
			[
				new textBox(TEXTBOX_INPUT.number, function(str) {
					PREFERENCES.connection_line_aa = clamp(real(str), 1, 4);
				}),
				__txtx("pref_connection_quality", "Render quality"),
				function() { return PREFERENCES.connection_line_aa; }
			],
			[
				new buttonGroup([ "None", "ALT", "Always" ], function(val) {
					PREFERENCES.connection_line_highlight = val;
				}),
				__txtx("pref_connection_highlight", "Highlight connection"),
				function() { return PREFERENCES.connection_line_highlight; }
			],
			[
				new slider(0, 1, 0.05, function(val) { 
					PREFERENCES.connection_line_highlight_fade = val; 
				}),
				__txtx("pref_connection_highlight_fade", "Fade connection"),
				function() { return PREFERENCES.connection_line_highlight_fade },
			],
			[
				new checkBox(function() { 
					PREFERENCES.connection_line_highlight_all = !PREFERENCES.connection_line_highlight_all; 
				}),
				__txtx("pref_connection_highlight_all", "Highlight all"),
				function() { return PREFERENCES.connection_line_highlight_all },
			],
		];
		
		setHeight();
	#endregion
}