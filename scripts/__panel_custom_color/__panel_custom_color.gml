function Panel_Custom_Color() : Panel_Custom_Element() constructor {
	type = "color";
	name = "Color";
	icon = THEME.panel_icon_element_color;
	
	selector = new colorSelector(function(c) /*=>*/ {return onModify(c)});
	selector.show_textbox = false;
	
	bind_input = new JuncLister("Input", CONNECT_TYPE.input);
	bg_output  = new JuncLister("BG",    CONNECT_TYPE.output);
	
	array_append(editors, [
		[ "Value Binding", false ], 
		bind_input,
		
		[ "BG", false ], 
		bg_output,
	]);
	
	////- Draw
	
	static onModify = function(t) {
		input_junc = bind_input.getJunction();
		if(input_junc) input_junc.setValue(cola(t, 1));
	}
	
	static draw = function(panel, _m) {
		input_junc = bind_input.getJunction();
		
		var _bg_junc = bg_output.getJunction();
		if(_bg_junc) {
			var _dat = _bg_junc.showValue();
			if(is_surface(_dat)) draw_surface_stretched_safe(_dat, x, y, w, h);
		}
		
		if(input_junc) {
			var _currVal = input_junc.showValue();
			if(_currVal != selector.current_color)
				selector.setColor(_currVal);
		}
		
		selector.drawSelector(x, y, w, h, _m, focus, elementHover);
	}
	
	////- Serialize
	
	static doSerialize = function(_m) {
		_m.bind = bind_input.serialize(_m);
		_m.bg   = bg_output.serialize(_m);
		return _m;
	}
	
	static doDeserialize = function(_m) { 
		bind_input.deserialize(_m.bind);
		bg_output.deserialize(_m.bg);
		return self;
	}
}