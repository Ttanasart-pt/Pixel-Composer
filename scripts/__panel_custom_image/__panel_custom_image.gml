function Panel_Custom_Image(_data) : Panel_Custom_Element(_data) constructor {
	type = "image";
	name = "Image";
	icon = THEME.panel_icon_element_image;
	
	color   = c_white;
	spr     = new Panel_Custom_Sprite("Sprite");
	
	array_append(editors, [
		spr, 
		Simple_Editor("Color", new buttonColor( function(c) /*=>*/ { color = c; }).hideAlpha(), function() /*=>*/ {return color}, function(c) /*=>*/ { color = c; }), 
	]);
	
	////- Draw
	
	static draw = function(panel, _m) {
		draw_sprite_stretched_ext_safe(spr.getSpr(), 0, x, y, w, h, color);
	}
	
	////- Serialize
	
	static doSerialize = function(_m) {
		_m.spr   = spr.serialize();
		_m.color = color;
		
		return _m;
	}
	
	static doDeserialize = function(_m) { 
		spr.deserialize(_m[$ "spr"]);
		color = _m[$ "color"] ?? color;
		return self;
	}
}