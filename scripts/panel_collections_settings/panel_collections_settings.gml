function Panel_Collections_Setting() : Panel_Linear_Setting() constructor {
	title = __txtx("collection_settings", "Collection Settings");
	
	w = ui(380);
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txt("View"),
			new buttonGroup([ "Grid", "List" ], function(i) { PANEL_COLLECTION.contentView = i; }),
			function() /*=>*/ {return PANEL_COLLECTION.contentView},
		),
		new __Panel_Linear_Setting_Item_Preference(
			__txtx("coll_animated", "Animated thumbnail"),
			"collection_animated",
			new checkBox(function() { PREFERENCES.collection_animated = !PREFERENCES.collection_animated; PREF_SAVE(); }),
		),
		new __Panel_Linear_Setting_Item_Preference(
			__txtx("coll_animated_speed", "Animation speed"),
			"collection_preview_speed",
			new textBox(TEXTBOX_INPUT.number, function(val) { PREFERENCES.collection_preview_speed = val; PREF_SAVE(); }),
		),
		new __Panel_Linear_Setting_Item_Preference(
			__txtx("coll_thumbnail_scale", "Thumbnail scale"),
			"collection_scale",
			slider(0, 1, 0.01, function(val) { PREFERENCES.collection_scale = clamp(val, 0.1, 1); PREF_SAVE(); }),
		),
	];
	
	setHeight();
}