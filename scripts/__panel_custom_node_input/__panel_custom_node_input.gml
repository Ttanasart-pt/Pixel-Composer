function Panel_Custom_Node_Input(_data) : Panel_Custom_Element(_data) constructor {
	type = "input";
	name = "Input";
	icon = THEME.panel_icon_element_node_input;
	
	input = new JuncLister(data, "Input", CONNECT_TYPE.input, true);
	
	font = 1;
	
	array_append(editors, [
		[ "Data", false ], 
		input, 
		
		[ "Text", false ], 
		Simple_Editor("Font", new scrollBox( [ 
			"Content 1", 
			"Content 2", 
			"Content 3", 
			"Content 4", 
		], function(t) /*=>*/ { font = t; } ), function() /*=>*/ {return font}, function(t) /*=>*/ { font = t; }), 
		
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
		
		var _junc = input.getJunction();
		if(_junc && input.editWidget) {
			var _dat   = _junc.showValue();
			var _param = new widgetParam(x, y, w, h, _dat, _junc.display_data, _m, rx, ry)
				.setFont(_font);
			
			var _inter = is(panel, Panel_Custom);
			input.editWidget.setInteract(_inter);
			input.editWidget.setFocusHover(_inter && focus, _inter && elementHover);
			input.editWidget.drawParam(_param);
			
		} else {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 3, x, y, w, h);
		}
		
	}
	
	////- Serialize
	
	static doSerialize = function(_m) {
		_m.font = font;
		
		_m.input = input.serialize(_m);
		return _m;
	}
	
	static doDeserialize = function(_m) { 
		font = _m[$ "font"] ?? font;
		
		if(has(_m, "input")) input.deserialize(_m.input);
		return self;
	}
}