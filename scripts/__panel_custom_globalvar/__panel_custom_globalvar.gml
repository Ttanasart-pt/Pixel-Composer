function Panel_Custom_Globalvar(_data) : Panel_Custom_Element(_data) constructor {
	type = "global";
	name = "Globalvar";
	icon = THEME.panel_icon_element_globalvar;
	
	globalkey = "";
	
	array_append(editors, [
		[ "Data", false ], 
		Simple_Editor("Globalvar", textArea_Text( function(t) /*=>*/ { globalkey = t; } ), function() /*=>*/ {return globalkey}, function(t) /*=>*/ { globalkey = t; }),
		
	]);
	
	////- Draw
	
	static draw = function(panel, _m) {
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 3, x, y, w, h);
		
	}
	
	////- Serialize
	
	static doSerialize = function(_m) {
		_m.globalkey = globalkey;
		return _m;
	}
	
	static doDeserialize = function(_m) { 
		globalkey = _m[$ "globalkey"] ?? globalkey;
		return self;
	}
}