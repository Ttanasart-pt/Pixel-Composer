function Panel_Preview_View_Setting() : Panel_Linear_Setting() constructor {
	title = __txtx("preview_view_settings", "View Settings");
	previewPanel = PROJECT.previewSetting;
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txt("Info"),
			new checkBox(function() /*=>*/ { previewPanel.show_info = !previewPanel.show_info; }),
			function()    /*=>*/   {return previewPanel.show_info},
			function(val) /*=>*/ { previewPanel.show_info = val; },
			PREFERENCES.project_previewSetting.show_info,
			["Preview", "Toggle Show Info"],
			"project_previewSetting.show_info",
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
			__txt("Ruler Color"),
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