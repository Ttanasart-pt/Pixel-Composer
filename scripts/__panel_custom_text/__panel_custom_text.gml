function Panel_Custom_Text() : Panel_Custom_Element() constructor {
	type = "text";
	name = "Text";
	icon = THEME.panel_icon_element_text;
	
	text   = "Text";
	font   = 4;
	color  = ca_white;
	halign = fa_left;
	valign = fa_top;
	
	array_append(editors, [
		[ "Text", false ], 
		new Panel_Custom_Element_Editor("Text", textArea_Text( function(t) /*=>*/ { text = t; } ), function() /*=>*/ {return text}, function(t) /*=>*/ { text = t; }), 
		new Panel_Custom_Element_Editor("Font", new scrollBox( [ 
			"Header 1", 
			"Header 3", 
			"Header 5", 
			"Content 1", 
			"Content 2", 
			"Content 2b", 
			"Content 3", 
			"Content 4", 
		], function(t) /*=>*/ { font = t; } ), function() /*=>*/ {return font}, function(t) /*=>*/ { font = t; }), 
		
		new Panel_Custom_Element_Editor("H Align", new buttonGroup( array_create(3, THEME.inspector_text_halign), function(c) /*=>*/ { halign = c; }), function() /*=>*/ {return halign}, function(c) /*=>*/ { halign = c; }), 
		new Panel_Custom_Element_Editor("V Align", new buttonGroup( array_create(3, THEME.inspector_text_valign), function(c) /*=>*/ { valign = c; }), function() /*=>*/ {return valign}, function(c) /*=>*/ { valign = c; }), 
		
		[ "Display", false ], 
		new Panel_Custom_Element_Editor("Color", new buttonColor( function(c) /*=>*/ { color = c; }), function() /*=>*/ {return color}, function(c) /*=>*/ { color = c; }), 
	]);
	
	////- Draw
	
	static draw = function(panel, _m) {
		var _font = f_p2;
		switch(font) {
			case 0 : _font = f_h1;  break;
			case 1 : _font = f_h3;  break;
			case 2 : _font = f_h5;  break;
			case 3 : _font = f_p1;  break;
			case 4 : _font = f_p2;  break;
			case 5 : _font = f_p2b; break;
			case 6 : _font = f_p3;  break;
			case 7 : _font = f_p4;  break;
		}
		
		var tx = x;
		switch(halign) {
			case fa_left   : tx = x;         break;
			case fa_center : tx = x + w / 2; break;
			case fa_right :  tx = x + w;     break;
		}
		
		var ty = y;
		switch(valign) {
			case fa_left   : ty = y;         break;
			case fa_center : ty = y + h / 2; break;
			case fa_right :  ty = y + h;     break;
		}
		
		draw_set_text(_font, halign, valign, color, _color_get_a(color));
		draw_text(tx, ty, text);
		draw_set_alpha(1);
		
		var _hov = hover && point_in_rectangle(_m[0], _m[1], x, y, x + w, y + h);
		if(_hov) panel.hovering_element = self;
	}
	
	////- Serialize
	
	static doSerialize = function(_m) {
		_m.text   = text;
		_m.font   = font;
		_m.color  = color;
		_m.halign = halign;
		_m.valign = valign;
		
		return _m;
	}
	
	static doDeserialize = function(_m) { 
		text =   _m[$ "text"]   ?? text;
		font =   _m[$ "font"]   ?? font;
		color =  _m[$ "color"]  ?? color;
		halign = _m[$ "halign"] ?? halign;
		valign = _m[$ "valign"] ?? valign;
		
		return self;
	}
}