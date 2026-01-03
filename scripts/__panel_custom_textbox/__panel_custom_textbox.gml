function Panel_Custom_Textbox() : Panel_Custom_Element() constructor {
	type = "textbox";
	name = "Textbox";
	icon = THEME.panel_icon_element_textbox;
	modifyContent = false;
	
	textbox = textBox_Text(function(t) /*=>*/ { onModify(t); }).setEmpty().setHide(3);
	
	bind_input = new JuncLister("Input", CONNECT_TYPE.input);
	
	bg_output    = new JuncLister("BG",     CONNECT_TYPE.output);
	hover_output = new JuncLister("Hover",  CONNECT_TYPE.output);
	press_output = new JuncLister("Select", CONNECT_TYPE.output);
	type = 0;
	
	halign = fa_left;
	valign = fa_top;
	color  = ca_white;
	
	array_append(editors, [
		[ "Value Binding", false ], 
		bind_input,
		
		[ "Textbox", false ], 
		Simple_Editor("Type", new scrollBox( [ 
			"Text", 
			"Number", 
		], function(t) /*=>*/ { type = t; } ), function() /*=>*/ {return type}, function(t) /*=>*/ { type = t; }), 
		
		[ "Textures", false ], 
		bg_output,
		hover_output,
		press_output,
		
		[ "Text", false ], 
		Simple_Editor("H Align", new buttonGroup( array_create(3, THEME.inspector_text_halign), function(c) /*=>*/ { halign = c; }), function() /*=>*/ {return halign}, function(c) /*=>*/ { halign = c; }), 
		Simple_Editor("V Align", new buttonGroup( array_create(3, THEME.inspector_text_valign), function(c) /*=>*/ { valign = c; }), function() /*=>*/ {return valign}, function(c) /*=>*/ { valign = c; }), 
		
		Simple_Editor("Color", new buttonColor( function(c) /*=>*/ { color = c; }), function() /*=>*/ {return color}, function(c) /*=>*/ { color = c; }), 
	]);
	
	////- Draw
	
	static onModify = function(t) {
		input_junc = bind_input.getJunction();
		if(input_junc) input_junc.setValue(t);
	}
	
	static draw = function(panel, _m) {
		input_junc = bind_input.getJunction();
		var hov = elementHover && point_in_rectangle(_m[0], _m[1], kx0, ky0, kx1, ky1);
		var pre = (hov && mouse_lclick(focus)) || textbox.selecting;
		
		var _bg_junc = bg_output.getJunction();
		if(_bg_junc) {
			var _dat = undefined;
			
			if(pre) {
				var _prs_junc = press_output.getJunction();
				if(_prs_junc) _dat = _prs_junc.showValue();
				
			} else if(hov) {
				var _hov_junc = hover_output.getJunction();
				if(_hov_junc) _dat = _hov_junc.showValue();
				
			} else 
				_dat = _bg_junc.showValue();
			
			if(is_surface(_dat)) draw_surface_stretched_safe(_dat, x, y, w, h);
			
		} else
			draw_sprite_stretched_ext(THEME.box_r2, 0, x, y, w, h, COLORS._main_icon_dark, 1);
		
		if(input_junc) {
			var _currVal = input_junc.showValue();
			var _param   = new widgetParam(x, y, w, h, _currVal, {}, _m, rx, ry)
				.setColor(color)
				.setHalign(halign)
				.setValign(valign);
			
			textbox.input = type;
			textbox.setFocusHover(focus, elementHover);
			textbox.drawParam(_param);
		}
	}
	
	////- Serialize
	
	static doSerialize = function(_m) {
		_m.bind  = bind_input.serialize(_m);
		_m.bg    = bg_output.serialize(_m);
		_m.hover = hover_output.serialize(_m);
		_m.press = press_output.serialize(_m);
		
		_m.type   = type;
		_m.color  = color;
		_m.halign = halign;
		_m.valign = valign;
		return _m;
	}
	
	static doDeserialize = function(_m) { 
		bind_input.deserialize(_m.bind);
		
		if(has(_m, "bg"))    bg_output.deserialize(_m.bg);
		if(has(_m, "hover")) hover_output.deserialize(_m.hover);
		if(has(_m, "press")) press_output.deserialize(_m.press);
		
		type   = _m[$ "type"]   ?? type;
		color  = _m[$ "color"]  ?? color;
		halign = _m[$ "halign"] ?? halign;
		valign = _m[$ "valign"] ?? valign;
		return self;
	}
}