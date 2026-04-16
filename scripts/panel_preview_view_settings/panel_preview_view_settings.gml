function Panel_Preview_View_Setting(_panel) : Panel_Linear_Setting() constructor {
	title = __txt("preview_view_settings", "View Settings");
	panel = _panel;
	previewPanel = PROJECT.previewSetting;
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txt("Info"),
			new buttonGroup(__txts([ "None", "Stacked", "Compact" ]), function(val) /*=>*/ { previewPanel.status_display = val; }),
			function()    /*=>*/   {return previewPanel.status_display},
			function(val) /*=>*/ { previewPanel.status_display = val; },
			PREFERENCES.project_previewSetting.status_display,
			noone,
			"project_previewSetting.status_display",
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("View Control"),
			new buttonGroup(__txts([ "None", "Left", "Right" ]), function(val) /*=>*/ { previewPanel.show_view_control = val; }),
			function()    /*=>*/   {return previewPanel.show_view_control},
			function(val) /*=>*/ { previewPanel.show_view_control = val; },
			PREFERENCES.project_previewSetting.show_view_control,
			noone,
			"project_previewSetting.show_view_control",
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Quick Nav"),
			new checkBox(function() /*=>*/ { previewPanel.quick_nav = !previewPanel.quick_nav; }),
			function()    /*=>*/   {return previewPanel.quick_nav},
			function(val) /*=>*/ { previewPanel.quick_nav = val; },
			PREFERENCES.project_previewSetting.quick_nav,
			noone,
			"project_previewSetting.quick_nav",
		),
		
		-1, 
		
		new __Panel_Linear_Setting_Item(
			__txt("Always show Left toolbar"),
			new checkBox(function() /*=>*/ { previewPanel.tool_always_l = !previewPanel.tool_always_l; }),
			function()    /*=>*/   {return previewPanel.tool_always_l},
			function(val) /*=>*/ { previewPanel.tool_always_l = val; },
			PREFERENCES.project_previewSetting.tool_always_l,
			noone,
			"project_previewSetting.tool_always_l",
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Always show Right toolbar"),
			new checkBox(function() /*=>*/ { previewPanel.tool_always_r = !previewPanel.tool_always_r; }),
			function()    /*=>*/   {return previewPanel.tool_always_r},
			function(val) /*=>*/ { previewPanel.tool_always_r = val; },
			PREFERENCES.project_previewSetting.tool_always_r,
			noone,
			"project_previewSetting.tool_always_r",
		),
		
		-1,
		
		new __Panel_Linear_Setting_Item(
			__txt("Ruler"),
			new checkBox(function() /*=>*/ { previewPanel.show_ruler = !previewPanel.show_ruler; }),
			function()    /*=>*/   {return previewPanel.show_ruler},
			function(val) /*=>*/ { previewPanel.show_ruler = val; },
			PREFERENCES.project_previewSetting.show_ruler,
			["Preview", "Toggle Ruler"],
			"project_previewSetting.show_ruler",
		),
		new __Panel_Linear_Setting_Item(
			__txt("Ruler Spacing"),
			textBox_Number(function(n) /*=>*/ { previewPanel.ruler_spacing = max(1, n); }),
			function()    /*=>*/   {return previewPanel.ruler_spacing},
			function(val) /*=>*/ { previewPanel.ruler_spacing = val; },
			PREFERENCES.project_previewSetting.ruler_spacing,
			noone,
			"project_previewSetting.ruler_spacing",
		),
		new __Panel_Linear_Setting_Item(
			__txt("Ruler Line Color"),
			new buttonColor(function(c) /*=>*/ { previewPanel.ruler_color = c; }),
			function()    /*=>*/   {return previewPanel.ruler_color},
			function(val) /*=>*/ { previewPanel.ruler_color = val; },
			PREFERENCES.project_previewSetting.ruler_color,
			noone,
			"project_previewSetting.ruler_color",
		),
	];
	
	setHeight();
}