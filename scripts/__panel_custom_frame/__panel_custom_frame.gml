function Panel_Custom_Frame() : Panel_Custom_Element() constructor {
	type = "frame";
	name = "Frame";
	icon = THEME.panel_icon_element_frame;
	is_container = true;
	
	style = 0;
	
	array_append(editors, [
		[ "Frame", false ], 
		Simple_Editor("Display", new scrollBox( [ 
			"None", 
			"Fill Only", 
			"Fill + Outline", 
			"Inner Panel", 
		], function(t) /*=>*/ { style = t; } ), function() /*=>*/ {return style}, function(t) /*=>*/ { style = t; }), 
	]);
	
	////- Draw
	
	static drawFrame = function(panel, _m) {}
	static draw      = function(panel, _m) {
		switch(style) {
			case 0 : break;
			case 1 : draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, x, y, w, h); break;
			case 2 : draw_sprite_stretched_ext(THEME.ui_panel_bg, 3, x, y, w, h); break;
			case 3 : draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, x, y, w, h); break;
		}
		
		drawFrame(panel, _m);
	}
	
	////- Serialize
	
	static frameSerialize = function(_m) {}
	static doSerialize = function(_m) {
		_m.style = style;
		frameSerialize(_m);
	}
	
	static frameDeserialize = function(_m) {}
	static doDeserialize = function(_m) {
		style = _m[$ "style"] ?? style;
		frameDeserialize(_m);
		return self;
	}
}