function Panel_Custom_Frame() : Panel_Custom_Element() constructor {
	type = "frame";
	name = "Frame";
	icon = THEME.panel_icon_element_frame;
	contents = [];
	
	style = 0;
	
	array_append(editors, [
		[ "Frame", false ], 
		new Panel_Custom_Element_Editor("Display", new scrollBox( [ 
			"None", 
			"Fill Only", 
			"Fill + Outline", 
			"Inner Panel", 
		], function(t) /*=>*/ { style = t; } ), function() /*=>*/ {return style}, function(t) /*=>*/ { style = t; }), 
	]);
	
	static setSize = function(_pBbox, _rx, _ry) {
		pbBox.base_bbox = _pBbox.getBBOX();
		bbox = pbBox.getBBOX(bbox);
		x  = bbox[0];
		y  = bbox[1];
		w  = bbox[2] - bbox[0];
		h  = bbox[3] - bbox[1];
		
		for( var i = 0, n = array_length(contents); i < n; i++ )
			contents[i].setSize(pbBox, _rx, _ry);
		
		rx = _rx;
		ry = _ry;
	}
	
	static draw = function(panel, _m) {
		var _hov = hover && point_in_rectangle(_m[0], _m[1], x, y, x + w, y + h);
		if(_hov) {
			panel.hovering_frame = self;
			if(key_mod_press(CTRL)) 
				panel.hovering_element = self;
		}
		
		switch(style) {
			case 0 : break;
			case 1 : draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, x, y, w, h); break;
			case 2 : draw_sprite_stretched_ext(THEME.ui_panel_bg, 3, x, y, w, h); break;
			case 3 : draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, x, y, w, h); break;
		}
		
		for( var i = 0, n = array_length(contents); i < n; i++ ) {
			var con = contents[i];
			con.setFocusHover(focus, hover);
			con.draw(panel, _m);
		}
	}
	
	static drawBox = function(panel) {
		var aa = .25 + .5 * (panel._hovering_element == self);
		draw_sprite_stretched_add(THEME.ui_panel, 1, x, y, w, h, COLORS._main_icon, aa);
		
		for( var i = 0, n = array_length(contents); i < n; i++ ) 
			contents[i].drawBox(panel);
	}
	
	static doDrawOutline = function(_depth, _panel, _x, _y, _w, _m, hov) {
		var lh = ui(24);
		
		if(_panel.element_adding) {
			if(_panel._hovering_frame == self)
				draw_sprite_stretched_ext(THEME.box_r2, 1, _x, _y - lh, _w, lh, COLORS._main_accent);
				
			if(hov) _panel.hovering_frame = self;
		}
		
		if(_panel.outline_drag && _panel.outline_drag != _panel._hovering_element) {
			var hovIn = point_in_rectangle(_m[0], _m[1], _x + _w - ui(32), _y - lh, _x + _w, _y);
			draw_sprite_ui_uniform(THEME.icon_default, 0, _x + _w - ui(16), _y - lh / 2, .75, 
				hovIn? COLORS._main_accent : COLORS._main_icon, .5 + .5 * hovIn);
			
			if(hovIn) _panel.outline_drag_frame = self;
		}
		
		var _h  = 0;
		var _y0 = _y;
		var _y1 = _y;
		
		for( var i = 0, n = array_length(contents); i < n; i++ ) {
			var con = contents[i];
			
			var hh = con.drawOutline(_depth + 1, _panel, _x + ui(16), _y, _w - ui(16), _m);
			_h += hh;
			_y += hh;
			if(i < n - 1) _y1 = _y;
		}
		
		if(n) {
			draw_set_color(CDEF.main_dark);
			draw_line(_x + ui(12), _y0, _x + ui(12), _y1 + lh / 2);
		}
		
		return _h;
	}
	
	////- Contents
	
	static addContent = function(cont) {
		array_push(contents, cont);
		cont.parent = self;
	}
	
	////- Serialize
	
	static frameSerialize = function(_m) {}
	static doSerialize = function(_m) {
		_m.style = style;
		_m.contents = array_map(contents, function(c) /*=>*/ {return c.serialize()});
		frameSerialize(_m);
	}
	
	static frameDeserialize = function(_m) {}
	static doDeserialize = function(_m) {
		style = _m[$ "style"] ?? style;
		
		for( var i = 0, n = array_length(_m.contents); i < n; i++ ) {
			var _con = new Panel_Custom_Element().deserialize(_m.contents[i]);
			addContent(_con);
		}
		
		frameDeserialize(_m);
		return self;
	}
}