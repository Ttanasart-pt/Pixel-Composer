function Panel_Custom_Frame(_data) : Panel_Custom_Element(_data) constructor {
	type = "frame";
	name = "Frame";
	icon = THEME.panel_icon_element_frame;
	is_container = true;
	
	style  = 0;
	color  = c_white;
	spr    = new Panel_Custom_Sprite("Sprite");
	
	fColor = c_white;
	fSpr   = new Panel_Custom_Sprite("Frame Sprite");
	
	array_append(editors, [
		[ "Frame", false ], 
		Simple_Editor("Display", new scrollBox( [ 
			"None", 
			"Fill Only", 
			"Fill + Outline", 
			"Inner Panel", 
			"Sprite", 
		], function(t) /*=>*/ { style = t; } ), function() /*=>*/ {return style}, function(t) /*=>*/ { style = t; }), 
		
		[ "Style", false ], 
		Simple_Editor("Color",       new buttonColor( function(c) /*=>*/ { color = c; }).hideAlpha(), function() /*=>*/ {return color}, function(c) /*=>*/ { color = c; }), 
		spr,
		Simple_Editor("Frame Color", new buttonColor( function(c) /*=>*/ { fColor = c; }).hideAlpha(), function() /*=>*/ {return fColor}, function(c) /*=>*/ { fColor = c; }), 
		fSpr, 
	]);
	
	////- Draw
	
	static drawFrame = function(panel, _m) {}
	static draw      = function(panel, _m) {
		spr.visible  = style == 4;
		fSpr.visible = style == 4;
		
		switch(style) {
			case 0 : break;
			case 1 : draw_sprite_stretched_ext(THEME.ui_panel_bg,  0, x, y, w, h,  color); break;
			case 2 : draw_sprite_stretched_ext(THEME.ui_panel_bg,  3, x, y, w, h,  color); break;
			case 3 : draw_sprite_stretched_ext(THEME.ui_panel_bg,  1, x, y, w, h,  color); break;
			case 4 : draw_sprite_stretched_ext_safe(spr.getSpr(),  0, x, y, w, h,  color); 
			         draw_sprite_stretched_ext_safe(fSpr.getSpr(), 0, x, y, w, h, fColor); break;
		}
		
		drawFrame(panel, _m);
	}
	
	////- Serialize
	
	static frameSerialize = function(_m) {}
	static doSerialize = function(_m) {
		_m.style  = style;
		
		_m.color  = color;
		_m.spr    = spr.serialize();
		
		_m.fColor = fColor;
		_m.fSpr   = fSpr.serialize();
		
		frameSerialize(_m);
	}
	
	static frameDeserialize = function(_m) {}
	static doDeserialize = function(_m) {
		style = _m[$ "style"] ?? style;
		
		color = _m[$ "color"] ?? color;
		spr.deserialize(_m[$ "spr"]);
		
		fColor = _m[$ "fColor"] ?? fColor;
		fSpr.deserialize(_m[$ "fSpr"]);
		
		frameDeserialize(_m);
		return self;
	}
}