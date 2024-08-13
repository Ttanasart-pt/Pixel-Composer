function Panel_Preview_Onion_Setting() : Panel_Linear_Setting() constructor {
	title = __txtx("preview_onion_skin_settings", "Onion skin Settings");
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txt("Enabled"),
			new checkBox(function() /*=>*/ { PROJECT.onion_skin.enabled = !PROJECT.onion_skin.enabled; }),
			function()    /*=>*/   {return PROJECT.onion_skin.enabled},
			function(val) /*=>*/ { PROJECT.onion_skin.enabled = val; },
			false,
			["Preview", "Toggle Onion Skin"]
		),
		new __Panel_Linear_Setting_Item(
			__txtx("onion_skin_top", "Draw on top"),
			new checkBox(function() /*=>*/ { PROJECT.onion_skin.on_top = !PROJECT.onion_skin.on_top; }),
			function()    /*=>*/   {return PROJECT.onion_skin.on_top},
			function(val) /*=>*/ { PROJECT.onion_skin.on_top = val; },
			true,
			["Preview", "Toggle Onion Skin view"]
		),
		new __Panel_Linear_Setting_Item(
			__txtx("onion_skin_frame_step", "Frame step"),
			new textBox(TEXTBOX_INPUT.number, function(str) /*=>*/ { PROJECT.onion_skin.step = max(1, round(real(str))); }),
			function()    /*=>*/   {return PROJECT.onion_skin.step},
			function(val) /*=>*/ { PROJECT.onion_skin.step = val; },
			1,
		),
		new __Panel_Linear_Setting_Item(
			__txtx("onion_skin_pre_color", "Pre Color"),
			new buttonColor(function(color) /*=>*/ { PROJECT.onion_skin.color[0] = color; }, self),
			function()    /*=>*/   {return PROJECT.onion_skin.color[0]},
			function(val) /*=>*/ { PROJECT.onion_skin.color[0] = val; },
			c_red,
		),
		new __Panel_Linear_Setting_Item(
			__txtx("onion_skin_post_color", "Post Color"),
			new buttonColor(function(color) /*=>*/ { PROJECT.onion_skin.color[1] = color; }, self),
			function()    /*=>*/   {return PROJECT.onion_skin.color[1]},
			function(val) /*=>*/ { PROJECT.onion_skin.color[1] = val; },
			c_blue,
		),
		new __Panel_Linear_Setting_Item(
			__txt("Opacity"),
			slider(0, 1, .05, function(str) /*=>*/ { PROJECT.onion_skin.alpha = clamp(real(str), 0, 1); }),
			function()    /*=>*/   {return PROJECT.onion_skin.alpha},
			function(val) /*=>*/ { PROJECT.onion_skin.alpha = val; },
			0.5,
		),
	];
	
	setHeight();
}