function Key_Displayer_Settings(_addon) : Panel_Linear_Setting() constructor {
	title = __txt("Key DIsplayer");
	addonInst = _addon;
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txt("Position"),
			new vectorBox(2, function(v,i) /*=>*/ { addonInst.position[i] = v; }),
			function( ) /*=>*/   {return addonInst.position},
			function(v) /*=>*/ { addonInst.position = v; },
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("H Align"),
			new buttonGroup([ "Left", "Right" ], function(v) /*=>*/ { addonInst.align_x = v; }),
			function( ) /*=>*/   {return addonInst.align_x},
			function(v) /*=>*/ { addonInst.align_x = v; },
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("V Align"),
			new buttonGroup([ "Top", "Bottom" ], function(v) /*=>*/ { addonInst.align_y = v; }),
			function( ) /*=>*/   {return addonInst.align_y},
			function(v) /*=>*/ { addonInst.align_y = v; },
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Scale"),
			slider(0, 1, .01, function(v) /*=>*/ { addonInst.dispScale = v; }),
			function( ) /*=>*/   {return addonInst.dispScale},
			function(v) /*=>*/ { addonInst.dispScale = v; },
		),
		
		-1, 
		
		new __Panel_Linear_Setting_Item(
			__txt("Mouse Color"),
			new buttonColor(function(v) /*=>*/ { addonInst.dispColor = v; }).hideAlpha(),
			function( ) /*=>*/   {return addonInst.dispColor},
			function(v) /*=>*/ { addonInst.dispColor = v; },
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Mouse Alpha"),
			slider(0, 1, .01, function(v) /*=>*/ { addonInst.dispAlpha = v; }),
			function( ) /*=>*/   {return addonInst.dispAlpha},
			function(v) /*=>*/ { addonInst.dispAlpha = v; },
		),
		
		-1,
	
		new __Panel_Linear_Setting_Item(
			__txt("Key Color"),
			new buttonColor(function(v) /*=>*/ { addonInst.keyColor = v; }).hideAlpha(),
			function( ) /*=>*/   {return addonInst.keyColor},
			function(v) /*=>*/ { addonInst.keyColor = v; },
		),
			
	];
	
	setHeight();
}