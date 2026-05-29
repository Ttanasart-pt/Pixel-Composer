function Panel_Animation_Region_Settings(_region) : Panel_Linear_Setting() constructor {
	title  = __txt("Region Settings");
	region = _region;
	w = ui(380);
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txt("Name"),
			textBox_Text(function(t) /*=>*/ { region.label = t; }),
			function( ) /*=>*/   {return region.label},
			function(v) /*=>*/ { region.label = v; },
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Color"),
			new buttonColor(function(c) /*=>*/ { region.color = c; }).hideAlpha(),
			function( ) /*=>*/   {return region.color},
			function(v) /*=>*/ { region.color = v; },
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Frame Start"),
			textBox_Number(function(t) /*=>*/ { region.frameStart = round(t); }).setSlideType(1)
				.setDeactivate(function() /*=>*/ {return PROJECT.regionUpdate()}),
			function( ) /*=>*/   {return region.frameStart},
			function(v) /*=>*/ { region.frameStart = v; PROJECT.regionUpdate(); },
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Frame End"),
			textBox_Number(function(t) /*=>*/ { region.frameEnd = round(t); }).setSlideType(1)
				.setDeactivate(function() /*=>*/ {return PROJECT.regionUpdate()}),
			function( ) /*=>*/   {return region.frameEnd},
			function(v) /*=>*/ { region.frameEnd = v; PROJECT.regionUpdate(); },
		),
		
	];
	
	setHeight();
}