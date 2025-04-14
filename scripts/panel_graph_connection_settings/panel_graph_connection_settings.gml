function Panel_Graph_Connection_Setting() : Panel_Linear_Setting() constructor {
	title = __txtx("graph_connection_settings", "Connection Settings");
	project         = PANEL_GRAPH.project;
	graphConnection = project.graphConnection;
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txt("Type"), 
			new buttonGroup(array_create(4, THEME.icon_curve_connection), function(val) /*=>*/ { graphConnection.type = val; }), 
			function( ) /*=>*/   {return graphConnection.type},
			function(v) /*=>*/ { graphConnection.type = v; },
			PREFERENCES.project_graphConnection.type,
			noone,
			"project_graphConnection.type",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("dialog_connection_thickness", "Line thickness"),
			new textBox(TEXTBOX_INPUT.number, function(str) /*=>*/ { graphConnection.line_width = max(0.5, real(str)); }),
			function( ) /*=>*/   {return graphConnection.line_width},
			function(v) /*=>*/ { graphConnection.line_width = v; },
			PREFERENCES.project_graphConnection.line_width,
			noone,
			"project_graphConnection.line_width",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("dialog_connection_radius", "Corner radius"),
			new textBox(TEXTBOX_INPUT.number, function(str) /*=>*/ { graphConnection.line_corner = max(0, real(str)); }),
			function( ) /*=>*/   {return graphConnection.line_corner},
			function(v) /*=>*/ { graphConnection.line_corner = v; },
			PREFERENCES.project_graphConnection.line_corner,
			noone,
			"project_graphConnection.line_corner",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("dialog_connection_extends", "Extends"),
			new textBox(TEXTBOX_INPUT.number, function(str) /*=>*/ { graphConnection.line_extend = max(0, real(str)); }),
			function( ) /*=>*/   {return graphConnection.line_extend},
			function(v) /*=>*/ { graphConnection.line_extend = v; },
			PREFERENCES.project_graphConnection.line_extend,
			noone,
			"project_graphConnection.line_extend",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("pref_connection_quality", "Render quality"),
			new textBox(TEXTBOX_INPUT.number, function(str) /*=>*/ { graphConnection.line_aa = clamp(real(str), 1, 4); }),
			function( ) /*=>*/   {return graphConnection.line_aa},
			function(v) /*=>*/ { graphConnection.line_aa = v; },
			PREFERENCES.project_graphConnection.line_aa,
			noone,
			"project_graphConnection.line_aa",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("pref_connection_highlight", "Highlight connection"),
			new buttonGroup(__txts([ "None", "ALT", "Always" ]), function(val) /*=>*/ { graphConnection.line_highlight = val; }), 
			function( ) /*=>*/   {return graphConnection.line_highlight},
			function(v) /*=>*/ { graphConnection.line_highlight = v; },
			PREFERENCES.project_graphConnection.line_highlight,
			noone,
			"project_graphConnection.line_highlight",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("pref_connection_highlight_fade", "Fade connection"),
			slider(0, 1, 0.05, function(val) /*=>*/ { graphConnection.line_highlight_fade = val; }),
			function( ) /*=>*/   {return graphConnection.line_highlight_fade},
			function(v) /*=>*/ { graphConnection.line_highlight_fade = v; },
			PREFERENCES.project_graphConnection.line_highlight_fade,
			noone,
			"project_graphConnection.line_highlight_fade",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("pref_connection_highlight_all", "Highlight all"),
			new checkBox(function() /*=>*/ { graphConnection.line_highlight_all = !graphConnection.line_highlight_all; }),
			function( ) /*=>*/   {return graphConnection.line_highlight_fade},
			function(v) /*=>*/ { graphConnection.line_highlight_fade = v; },
			PREFERENCES.project_graphConnection.line_highlight_fade,
			noone,
			"project_graphConnection.line_highlight_fade",
		),
	];
	
	setHeight();
}