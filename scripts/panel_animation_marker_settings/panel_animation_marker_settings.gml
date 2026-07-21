function Panel_Animation_Marker_Settings(_marker) : Panel_Linear_Setting() constructor {
	title  = __txt("Marker Settings");
	marker = _marker;
	w = ui(380);
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txt("Position"),
			textBox_Number(function(n) /*=>*/ { marker.frame = n; }),
			function( ) /*=>*/   {return marker.frame},
			function(v) /*=>*/ { marker.frame = v; },
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Label"),
			textBox_Text(function(t) /*=>*/ { marker.label = t; }).setEmpty(),
			function( ) /*=>*/   {return marker.label},
			function(v) /*=>*/ { marker.label = v; },
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Color"),
			new buttonColor(function(c) /*=>*/ { marker.color = c; }).hideAlpha(),
			function( ) /*=>*/   {return marker.color},
			function(v) /*=>*/ { marker.color = v; },
		),
		
	];
	
	setHeight();
}