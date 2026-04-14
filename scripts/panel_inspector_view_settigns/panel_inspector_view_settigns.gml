function Panel_Inspector_View_Settings() : Panel_Linear_Setting() constructor {
	title = __txtx("inspector_view_settings", "View Settings");
	
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
			new textArrayBox(function() /*=>*/ {return PREFERENCES.widget_draw_order}, [ "Reset", "Set Default" ]),
			function( ) /*=>*/   {return PREFERENCES.widget_draw_order},
			function(v) /*=>*/ { PREFERENCES.widget_draw_order = array_clone(v); },
			PREFERENCES.widget_draw_order,
			noone,
			"widget_draw_order",
		),
		
		// new __Panel_Linear_Setting_Item(
		// 	__txt("Reset Button"),
		// 	new checkBox(() => { PREFERENCES.widget_draw_reset = !PREFERENCES.widget_draw_reset; }),
		// 	( ) =>   PREFERENCES.widget_draw_reset,
		// 	(v) => { PREFERENCES.widget_draw_reset = v; },
		// 	PREFERENCES.widget_draw_reset,
		// 	noone,
		// 	"widget_draw_reset",
		// ),
		
		// new __Panel_Linear_Setting_Item(
		// 	__txt("Default Button"),
		// 	new checkBox(() => { PREFERENCES.widget_draw_default = !PREFERENCES.widget_draw_default; }),
		// 	( ) =>   PREFERENCES.widget_draw_default,
		// 	(v) => { PREFERENCES.widget_draw_default = v; },
		// 	PREFERENCES.widget_draw_default,
		// 	noone,
		// 	"widget_draw_default",
		// ),
		
	];
	
	setHeight();
}