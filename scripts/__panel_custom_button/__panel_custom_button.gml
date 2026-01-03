function Panel_Custom_Button() : Panel_Custom_Element() constructor {
	type = "button";
	name = "Button";
	icon = THEME.panel_icon_element_button;
	
	bind_input  = new JuncLister("Input",  CONNECT_TYPE.input);
	bind_action = new JuncLister("Action", CONNECT_TYPE.input);
	bind_output = new JuncLister("Output", CONNECT_TYPE.output);
	
	bg_output    = new JuncLister("Idle",   CONNECT_TYPE.output);
	hover_output = new JuncLister("Hover",  CONNECT_TYPE.output);
	press_output = new JuncLister("Press",  CONNECT_TYPE.output);
	
	array_append(editors, [
		[ "Value Binding", false ], 
		bind_input,
		
		[ "Action", false ], 
		bind_action,
		bind_output,
		
		[ "Textures", false ], 
		bg_output,
		hover_output,
		press_output,
	]);
	
	////- Draw
	
	static draw = function(panel, _m) {
		input_junc  = bind_input.getJunction();
		action_junc = bind_action.getJunction();
		output_junc = bind_output.getJunction();
		
		var hov = elementHover && point_in_rectangle(_m[0], _m[1], x, y, x + w, y + h);
		var pre = hov && mouse_lclick(focus);
		
		var _bg_junc  = bg_output.getJunction();
		
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
			
			draw_surface_stretched_safe(_dat, x, y, w, h);	
			
		} else {
			draw_sprite_stretched_ext(THEME.box_r2, 0, x, y, w, h, COLORS._main_icon, 1);
			draw_sprite_stretched_add(THEME.box_r2, 0, x, y, w, h, COLORS._main_icon, pre * .2);
			draw_sprite_stretched_add(THEME.box_r2, 1, x, y, w, h, COLORS._main_icon, .2 + .3 * hov);
		}
		
		if(input_junc && output_junc) {
			if(hov && mouse_lpress(focus)) {
				if(action_junc) {
					var _val = input_junc.getValue();
					action_junc.setValue(_val);
				}
				Render();
				
				var _res = output_junc.getValue();
				input_junc.setValue(_res);
			}
		}
		
	}
	
	////- Serialize
	
	static doSerialize = function(_m) {
		_m.bind = bind_input.serialize(_m);
		_m.actn = bind_action.serialize(_m);
		_m.acto = bind_output.serialize(_m);
		
		_m.bg    = bg_output.serialize(_m);
		_m.hover = hover_output.serialize(_m);
		_m.press = press_output.serialize(_m);
		return _m;
	}
	
	static doDeserialize = function(_m) { 
		bind_input.deserialize(_m.bind);
		bind_action.deserialize(_m.actn);
		bind_output.deserialize(_m.acto);
		
		if(has(_m, "bg"))    bg_output.deserialize(_m.bg);
		if(has(_m, "hover")) hover_output.deserialize(_m.hover);
		if(has(_m, "press")) press_output.deserialize(_m.press);
		return self;
	}
}