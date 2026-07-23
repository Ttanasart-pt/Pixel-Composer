function Panel_Animation_Analyze_Settings() : Panel_Linear_Setting() constructor {
	title = __txt("analyze_settings", "Analyzer");
	w = ui(380);

	properties = [
		new __Panel_Linear_Setting_Item(
			__txt("Analyze"),
			new checkBox(function() /*=>*/ { PANEL_ANIMATION.animation_analyze = !PANEL_ANIMATION.animation_analyze; }),
			function( ) /*=>*/ {return PANEL_ANIMATION.animation_analyze},
			function(v) /*=>*/ { PANEL_ANIMATION.animation_analyze = v; },
			false,
		),
		
		-1, 
		
		new __Panel_Linear_Setting_Item(
			__txt("Velocity"),
			new checkBox(function() /*=>*/ { PANEL_ANIMATION.analyze_velocity = !PANEL_ANIMATION.analyze_velocity; }),
			function( ) /*=>*/ {return PANEL_ANIMATION.analyze_velocity},
			function(v) /*=>*/ { PANEL_ANIMATION.analyze_velocity = v; },
			false,
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Pixel Delta"),
			new checkBox(function() /*=>*/ { PANEL_ANIMATION.analyze_delta_pixel = !PANEL_ANIMATION.analyze_delta_pixel; }),
			function( ) /*=>*/ {return PANEL_ANIMATION.analyze_delta_pixel},
			function(v) /*=>*/ { PANEL_ANIMATION.analyze_delta_pixel = v; },
			false,
		),
		
	];
	
	setHeight();
	
}