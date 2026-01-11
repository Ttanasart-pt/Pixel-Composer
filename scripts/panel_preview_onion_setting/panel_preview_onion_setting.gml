function Panel_Preview_Onion_Setting() : Panel_Linear_Setting() constructor {
	title = __txtx("preview_onion_skin_settings", "Onion skin Settings");
	onion = PROJECT.onion_skin;
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txt("Enabled"),
			new checkBox(function() /*=>*/ { onion.enabled = !onion.enabled; }),
			function( ) /*=>*/   {return onion.enabled},
			function(v) /*=>*/ { onion.enabled = v; },
			false,
			["Preview", "Toggle Onion Skin"]
		),
		new __Panel_Linear_Setting_Item(
			__txtx("onion_skin_top", "Draw on top"),
			new checkBox(function() /*=>*/ { onion.on_top = !onion.on_top; }),
			function( ) /*=>*/   {return onion.on_top},
			function(v) /*=>*/ { onion.on_top = v; },
			true,
			["Preview", "Toggle Onion Skin view"]
		),
		new __Panel_Linear_Setting_Item(
			__txtx("onion_skin_frame_range", "Range"),
			new vectorBox(2, function(v,i) /*=>*/ { onion.range[i] = v; }).setLinkable(false),
			function( ) /*=>*/   {return onion.range},
			function(v) /*=>*/ { onion.range = v; },
			[-1,1],
		),
		new __Panel_Linear_Setting_Item(
			__txtx("onion_skin_frame_step", "Frame step"),
			textBox_Number(function(str) /*=>*/ { onion.step = max(1, round(real(str))); }),
			function( ) /*=>*/   {return onion.step},
			function(v) /*=>*/ { onion.step = v; },
			1,
		),
		new __Panel_Linear_Setting_Item(
			__txtx("onion_skin_pre_color", "Pre Color"),
			new buttonColor(function(color) /*=>*/ { onion.color[0] = color; }, self),
			function( ) /*=>*/   {return onion.color[0]},
			function(v) /*=>*/ { onion.color[0] = v; },
			c_red,
		),
		new __Panel_Linear_Setting_Item(
			__txtx("onion_skin_post_color", "Post Color"),
			new buttonColor(function(color) /*=>*/ { onion.color[1] = color; }, self),
			function( ) /*=>*/   {return onion.color[1]},
			function(v) /*=>*/ { onion.color[1] = v; },
			c_blue,
		),
		new __Panel_Linear_Setting_Item(
			__txt("Opacity"),
			slider(0, 1, .05, function(str) /*=>*/ { onion.alpha = clamp(real(str), 0, 1); }),
			function( ) /*=>*/   {return onion.alpha},
			function(v) /*=>*/ { onion.alpha = v; },
			0.5,
		),
	];
	
	setHeight();
}