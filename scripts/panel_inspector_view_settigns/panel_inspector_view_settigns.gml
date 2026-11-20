function Panel_Inspector_View_Settings() : Panel_Linear_Setting() constructor {
	title = __txt("inspector_view_settings", "View Settings");
	
	prop_general = [
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
			new textArrayBox(function() /*=>*/ {return PREFERENCES.widget_draw_order}, WIDGET_RIGHT_BUTTONS, function() /*=>*/ {return PREF_SAVE()}),
			function( ) /*=>*/   {return PREFERENCES.widget_draw_order},
			function(v) /*=>*/ { PREFERENCES.widget_draw_order = array_clone(v); },
			PREFERENCES.widget_draw_order,
			noone,
			"widget_draw_order",
		),
		
	];
	
	prop_exp = [
		new __Panel_Linear_Setting_Item(
			__txt("Right Button (anim)"),
			new textArrayBox(function() /*=>*/ {return PREFERENCES.widget_exp_draw_order_anim}, WIDGET_RIGHT_ANIM_BUTTONS, function() /*=>*/ {return PREF_SAVE()}),
			function( ) /*=>*/   {return PREFERENCES.widget_exp_draw_order_anim},
			function(v) /*=>*/ { PREFERENCES.widget_exp_draw_order_anim = array_clone(v); },
			PREFERENCES.widget_exp_draw_order_anim,
			noone,
			"widget_exp_draw_order_anim",
		),
	];
	
	prop_com = [
		new __Panel_Linear_Setting_Item(
			__txt("Right Button (anim)"),
			new textArrayBox(function() /*=>*/ {return PREFERENCES.widget_draw_order_anim}, WIDGET_RIGHT_ANIM_BUTTONS, function() /*=>*/ {return PREF_SAVE()}),
			function( ) /*=>*/   {return PREFERENCES.widget_draw_order_anim},
			function(v) /*=>*/ { PREFERENCES.widget_draw_order_anim = array_clone(v); },
			PREFERENCES.widget_draw_order_anim,
			noone,
			"widget_draw_order_anim",
		),
	];
	
	properties = array_merge(prop_general, PANEL_INSPECTOR.viewMode? prop_exp : prop_com);
	_viewMode = PANEL_INSPECTOR.viewMode;
	
	setHeight();
	
	static onDraw = function() {
		if(_viewMode != PANEL_INSPECTOR.viewMode) {
			properties = array_merge(prop_general, PANEL_INSPECTOR.viewMode? prop_exp : prop_com);
			setHeight();
			_viewMode = PANEL_INSPECTOR.viewMode;
		}
	}
	
}