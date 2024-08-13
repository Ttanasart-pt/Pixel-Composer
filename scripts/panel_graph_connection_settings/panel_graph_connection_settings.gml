function Panel_Graph_Connection_Setting() : Panel_Linear_Setting() constructor {
	title = __txtx("graph_connection_settings", "Connection Settings");
	
	properties = [
		new __Panel_Linear_Setting_Item_Preference(
			__txt("Type"), 
			"curve_connection_line",
			new buttonGroup([ THEME.icon_curve_connection, THEME.icon_curve_connection, THEME.icon_curve_connection, THEME.icon_curve_connection ], 
				function(val) { PREFERENCES.curve_connection_line = val; }), 
		),
		new __Panel_Linear_Setting_Item_Preference(
			__txtx("dialog_connection_thickness", "Line thickness"),
			"connection_line_width",
			new textBox(TEXTBOX_INPUT.number, function(str) { PREFERENCES.connection_line_width = max(0.5, real(str)); }),
		),
		new __Panel_Linear_Setting_Item_Preference(
			__txtx("dialog_connection_radius", "Corner radius"),
			"connection_line_corner",
			new textBox(TEXTBOX_INPUT.number, function(str) { PREFERENCES.connection_line_corner = max(0, real(str)); }),
		),
		new __Panel_Linear_Setting_Item_Preference(
			__txtx("pref_connection_quality", "Render quality"),
			"connection_line_aa",
			new textBox(TEXTBOX_INPUT.number, function(str) { PREFERENCES.connection_line_aa = clamp(real(str), 1, 4); }),
		),
		new __Panel_Linear_Setting_Item_Preference(
			__txtx("pref_connection_highlight", "Highlight connection"),
			"connection_line_highlight",
			new buttonGroup([ "None", "ALT", "Always" ], function(val) { PREFERENCES.connection_line_highlight = val; }), 
		),
		new __Panel_Linear_Setting_Item_Preference(
			__txtx("pref_connection_highlight_fade", "Fade connection"),
			"connection_line_highlight_fade",
			slider(0, 1, 0.05, function(val) { PREFERENCES.connection_line_highlight_fade = val; }),
		),
		new __Panel_Linear_Setting_Item_Preference(
			__txtx("pref_connection_highlight_all", "Highlight all"),
			"connection_line_highlight_all",
			new checkBox(function() { PREFERENCES.connection_line_highlight_all = !PREFERENCES.connection_line_highlight_all; }),
		),
	];
	
	setHeight();
}