function Panel_Canvas_BG_Setting(_canvas) : Panel_Linear_Setting() constructor {
	title      = __txt("preview_bg_settings", "Background Settings");
	canvas     = _canvas;
	node       = canvas.node;
	attributes = node.attributes;
	
	properties = [
		new __Panel_Linear_Setting_Label( "These settings will only apply to editor view.", THEME.noti_icon_warning, 1, COLORS._main_accent ),
		
		new __Panel_Linear_Setting_Item(
			__txt("Visible"),
			new checkBox(function() /*=>*/ { canvas.bg_show = !canvas.bg_show; }),
			function( ) /*=>*/   {return canvas.bg_show},
			function(v) /*=>*/ { canvas.bg_show = v; }
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Sync to Preview"),
			new checkBox(function() /*=>*/ { canvas.sync_preview = !canvas.sync_preview; }),
			function( ) /*=>*/   {return canvas.sync_preview},
			function(v) /*=>*/ { canvas.sync_preview = v; }
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Alpha"),
			slider(0, 1, .01, function(v) /*=>*/ { canvas.bg_alpha = v; }),
			function( ) /*=>*/   {return canvas.bg_alpha},
			function(v) /*=>*/ { canvas.bg_alpha = v; }
		),
		
		-1, 
		
		new __Panel_Linear_Setting_Item(
			__txt("Tool Outline"),
			new checkBox(function() /*=>*/ { canvas.tool_outline = !canvas.tool_outline; }),
			function( ) /*=>*/   {return canvas.tool_outline},
			function(v) /*=>*/ { canvas.tool_outline = v; }
		),
		
	];

	setHeight();
}