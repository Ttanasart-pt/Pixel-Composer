function Panel_Custom_Choices(_data) : Panel_Custom_Element(_data) constructor {
	type = "choices";
	name = "Choices";
	icon = THEME.panel_icon_element_choices;
	modifyContent = false;
	
	bind_input = new JuncLister(data, "Input", CONNECT_TYPE.input);
	bg_output  = new JuncLister(data, "BG",    CONNECT_TYPE.output);
	
	array_append(editors, [
		[ "Value Binding", false ], 
		bind_input,
		
		[ "BG", false ], 
		bg_output,
	]);
	
	////- Draw
	
	static draw = function(panel, _m) {
		input_junc = bind_input.getJunction();
		
		var _bg_junc = bg_output.getJunction();
		if(_bg_junc) {
			var _dat = _bg_junc.showValue();
			if(is_surface(_dat)) draw_surface_stretched_safe(_dat, x, y, w, h);
			
		} else
			draw_sprite_stretched_ext(THEME.box_r2, 0, x, y, w, h, COLORS._main_icon_dark, 1);
		
		if(input_junc) {
			var _currVal = input_junc.showValue();
			
		}
		
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