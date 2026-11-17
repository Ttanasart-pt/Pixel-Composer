function Panel_Inspector_View_Settings() : Panel_Linear_Setting() constructor {
	title = __txt("inspector_view_settings", "View Settings");
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txt("Type"), 
			new buttonGroup([ "Compact", "Spacious" ], function(val) /*=>*/ { 
        		PREFERENCES.inspector_view_default = val;
				PANEL_INSPECTOR.viewMode = val 
			}), 
			function( ) /*=>*/   {return PANEL_INSPECTOR.viewMode},
			function(v) /*=>*/ { PANEL_INSPECTOR.viewMode = v; },
			PREFERENCES.inspector_view_default,
			noone,
			"inspector_view_default",
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Expands Section"),
			new checkBox(function() /*=>*/ { PREFERENCES.inspector_expand_section = !PREFERENCES.inspector_expand_section; }),
			function( ) /*=>*/   {return PREFERENCES.inspector_expand_section},
			function(v) /*=>*/ { PREFERENCES.inspector_expand_section = v; },
			PREFERENCES.inspector_expand_section,
			noone,
			"inspector_expand_section",
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Simplified Icon"),
			new checkBox(function() /*=>*/ { PREFERENCES.inspector_draw_key = !PREFERENCES.inspector_draw_key; }),
			function( ) /*=>*/   {return PREFERENCES.inspector_draw_key},
			function(v) /*=>*/ { PREFERENCES.inspector_draw_key = v; },
			PREFERENCES.inspector_draw_key,
			noone,
			"inspector_draw_key",
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Node Chain"),
			new checkBox(function() /*=>*/ { PREFERENCES.inspector_show_node_chain = !PREFERENCES.inspector_show_node_chain; }),
			function( ) /*=>*/   {return PREFERENCES.inspector_show_node_chain},
			function(v) /*=>*/ { PREFERENCES.inspector_show_node_chain = v; },
			PREFERENCES.inspector_show_node_chain,
			noone,
			"inspector_show_node_chain",
		),
		
		-1,
		
		new __Panel_Linear_Setting_Item(
			__txt("Favourite Button"),
			new checkBox(function() /*=>*/ { PREFERENCES.widget_draw_favourite = !PREFERENCES.widget_draw_favourite; }),
			function( ) /*=>*/   {return PREFERENCES.widget_draw_favourite},
			function(v) /*=>*/ { PREFERENCES.widget_draw_favourite = v; },
			PREFERENCES.widget_draw_favourite,
			noone,
			"widget_draw_favourite",
		),
		
		-1, 
		
		new __Panel_Linear_Setting_Item(
			__txt("Right Button"),
			new textArrayBox(function() /*=>*/ {return PREFERENCES.widget_draw_order}, [ "Reset", "Set Default", "Expression", "Bypass", "Favourite" ], function() /*=>*/ {return PREF_SAVE()}),
			function( ) /*=>*/   {return PREFERENCES.widget_draw_order},
			function(v) /*=>*/ { PREFERENCES.widget_draw_order = array_clone(v); },
			PREFERENCES.widget_draw_order,
			noone,
			"widget_draw_order",
		),
		
	];
	
	setHeight();
}