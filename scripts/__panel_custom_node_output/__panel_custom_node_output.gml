function Panel_Custom_Node_Output(_data) : Panel_Custom_Element(_data) constructor {
	type = "output";
	name = "Output";
	icon = THEME.panel_icon_element_node_output;
	
	output = new JuncLister(data, "Output", CONNECT_TYPE.output, true);
	
	dataOnly = true;
	font     = 1;
	halign   = fa_left;
	valign   = fa_top;
	color    = ca_white;
	surface_fit  = 0;
	surface_tile = 0;
	
	array_append(editors, [
		[ "Data", false ], 
		output, 
		
		Simple_Editor("Data Only", new checkBox( function() /*=>*/ { dataOnly = !dataOnly; } ), function() /*=>*/ {return dataOnly}, function(t) /*=>*/ { dataOnly = t; }), 
		
		[ "Text", false ], 	
		Simple_Editor("Font", new scrollBox( [ 
			"Content 1", 
			"Content 2", 
			"Content 3", 
			"Content 4", 
		], function(t) /*=>*/ { font = t; } ), function() /*=>*/ {return font}, function(t) /*=>*/ { font = t; }), 
		Simple_Editor("H Align", new buttonGroup( array_create(3, THEME.inspector_text_halign), function(c) /*=>*/ { halign = c; }), function() /*=>*/ {return halign}, function(c) /*=>*/ { halign = c; }), 
		Simple_Editor("V Align", new buttonGroup( array_create(3, THEME.inspector_text_valign), function(c) /*=>*/ { valign = c; }), function() /*=>*/ {return valign}, function(c) /*=>*/ { valign = c; }), 
		Simple_Editor("Surface Fit", new scrollBox( [ 
			"Keep Ratio min", 
			"Keep Ratio max", 
			"Stretch", 
		], function(t) /*=>*/ { surface_fit = t; } ), function() /*=>*/ {return surface_fit}, function(t) /*=>*/ { surface_fit = t; }), 
		Simple_Editor("Tile", new checkBox( function() /*=>*/ { surface_tile = !surface_tile; } ), function() /*=>*/ {return surface_tile}, function(t) /*=>*/ { surface_tile = t; }), 
		
		[ "Display", false ], 	
		Simple_Editor("Color", new buttonColor( function(c) /*=>*/ { color = c; }), function() /*=>*/ {return color}, function(c) /*=>*/ { color = c; }), 
	]);
	
	////- Draw
	
	static draw = function(panel, _m) {
		var _font = f_p2;
		switch(font) {
			case 0 : _font = f_p1; break;
			case 1 : _font = f_p2; break;
			case 2 : _font = f_p3; break;
			case 3 : _font = f_p4; break;
		}
		
		var _junc = output.getJunction();
		if(_junc) {
			var _dat = _junc.showValue();
			
			if(dataOnly) {
				switch(_junc.type) {
					case VALUE_TYPE.surface : 
						if(!is_surface(_dat)) break;
						
						if(surface_fit == 2) {
							draw_surface_stretched_ext(_dat, x, y, w, h, color, _color_get_a(color));
							break;
						}
						
						var sw = surface_get_width(_dat);
						var sh = surface_get_height(_dat);
						var ss = surface_fit? max(w / sw, h / sh) : min(w / sw, h / sh);
						var sww = sw * ss;
						var shh = sh * ss;
						
						var tx = x;
						var ty = y;
						
						switch(halign) {
							case fa_left   : tx = x;                   break;
							case fa_center : tx = x + w / 2 - sww / 2; break;
							case fa_right :  tx = x + w - sww;         break;
						}
						
						switch(valign) {
							case fa_left   : ty = y;                   break;
							case fa_center : ty = y + h / 2 - shh / 2; break;
							case fa_right :  ty = y + h - shh;         break;
						}
						
						var scis = gpu_get_scissor();
						gpu_set_scissor(x,y,w,h);
						
						if(surface_tile) draw_surface_tiled_ext_safe(_dat, tx, ty, ss, ss, 0, color, _color_get_a(color));
						else draw_surface_ext_safe(_dat, tx, ty, ss, ss, 0, color, _color_get_a(color));
						gpu_set_scissor(scis);
						break;
						
					default :
						var tx = x;
						var ty = y;
						
						switch(halign) {
							case fa_left   : tx = x;         break;
							case fa_center : tx = x + w / 2; break;
							case fa_right :  tx = x + w;     break;
						}
						
						switch(valign) {
							case fa_left   : ty = y;         break;
							case fa_center : ty = y + h / 2; break;
							case fa_right :  ty = y + h;     break;
						}
						
						draw_set_text(_font, halign, valign, color, _color_get_a(color));
						draw_text(tx, ty, string(_dat));
						draw_set_alpha(1);
				} 
				
			} else if(output.getEditWidget()) {
				var _param = new widgetParam(x, y, w, h, _dat, _junc.display_data, _m, rx, ry)	
					.setFont(_font)
					.setHalign(halign)
					.setValign(valign)
					.setColor(color)
					
				output.getEditWidget().drawParam(_param);
			}
		}
		
	}
	
	////- Serialize
	
	static doSerialize = function(_m) {
		_m.dataOnly = dataOnly;
		_m.font     = font;
		_m.halign   = halign;
		_m.valign   = valign;
		_m.color    = color;
		
		_m.surface_fit  = surface_fit;
		_m.surface_tile = surface_tile;
		
		_m.output = output.serialize(_m);
		return _m;
	}
	
	static doDeserialize = function(_m) { 
		dataOnly = _m[$ "dataOnly"]    ?? dataOnly;
		font     = _m[$ "font"]        ?? font;
		halign   = _m[$ "halign"]      ?? halign;
		valign   = _m[$ "valign"]      ?? valign;
		color    = _m[$ "color"]       ?? color;
		
		surface_fit  = _m[$ "surface_fit"] ?? surface_fit;
		surface_tile = _m[$ "surface_tile"] ?? surface_tile;
		
		if(has(_m, "output")) output.deserialize(_m.output);
		return self;
	}
}