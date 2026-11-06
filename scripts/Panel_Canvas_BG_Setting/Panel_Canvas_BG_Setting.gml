function Panel_Canvas_BG_Setting(_canvas) : Panel_Linear_Setting() constructor {
	title      = __txt("preview_bg_settings", "Background Settings");
	canvas     = _canvas;
	node       = canvas.node;
	attributes = node.attributes;
	
	properties = [
		new __Panel_Linear_Setting_Label( "These settings will only apply to editor view.", THEME.noti_icon_warning, 1, COLORS._main_accent ),
		
		new __Panel_Linear_Setting_Item(
			__txt("Visible"),
			new checkBox(function() /*=>*/ { attributes.bg_show = !attributes.bg_show; }),
			function( ) /*=>*/   {return attributes.bg_show},
			function(v) /*=>*/ { attributes.bg_show = v; }
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Sync to Preview"),
			new checkBox(function() /*=>*/ { attributes.sync_preview = !attributes.sync_preview; }),
			function( ) /*=>*/   {return attributes.sync_preview},
			function(v) /*=>*/ { attributes.sync_preview = v; }
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Alpha"),
			slider(0, 1, .01, function(v) /*=>*/ { attributes.bg_alpha = v; }),
			function( ) /*=>*/   {return attributes.bg_alpha},
			function(v) /*=>*/ { attributes.bg_alpha = v; }
		),
		
		-1, 
		
		new __Panel_Linear_Setting_Item(
			__txt("Tool Outline"),
			new checkBox(function() /*=>*/ { attributes.tool_outline = !attributes.tool_outline; }),
			function( ) /*=>*/   {return attributes.tool_outline},
			function(v) /*=>*/ { attributes.tool_outline = v; }
		),
		
	];

	setHeight();
}