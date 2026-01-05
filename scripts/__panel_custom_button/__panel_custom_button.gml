function Panel_Custom_Button(_data) : Panel_Custom_Element(_data) constructor {
	type = "button";
	name = "Button";
	icon = THEME.panel_icon_element_button;
	
	bind_input  = new JuncLister(data, "Input",  CONNECT_TYPE.input);
	bind_action = new JuncLister(data, "Action", CONNECT_TYPE.input);
	bind_output = new JuncLister(data, "Output", CONNECT_TYPE.output);
	
	bg_output    = new JuncLister(data, "Idle",   CONNECT_TYPE.output);
	hover_output = new JuncLister(data, "Hover",  CONNECT_TYPE.output);
	press_output = new JuncLister(data, "Press",  CONNECT_TYPE.output);
	
	isSetValue = false;
	setValue   = 0;
	
	array_append(editors, [
		[ "Value Binding", false ], 
		bind_input,
		
		[ "Node Action", false ], 
		bind_action,
		bind_output,
		
		[ "Set Value", false ], 
		Simple_Editor("Set Value", new checkBox( function() /*=>*/ { isSetValue = !isSetValue; } ), function() /*=>*/ {return isSetValue}, function(t) /*=>*/ { isSetValue = t; }), 
		Simple_Editor("Value", textArea_Number( function(t) /*=>*/ { setValue = t; } ), function() /*=>*/ {return setValue}, function(t) /*=>*/ { setValue = t; }), 
		
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
			var _prs_junc = press_output.getJunction();
			var _hov_junc = hover_output.getJunction();
			
			     if(pre && _prs_junc) _dat = _prs_junc.showValue();
			else if(hov && _hov_junc) _dat = _hov_junc.showValue();
			else                      _dat = _bg_junc.showValue();
			
			draw_surface_stretched_safe(_dat, x, y, w, h);	
			
		} else {
			draw_sprite_stretched_ext(THEME.box_r2, 0, x, y, w, h, COLORS._main_icon, 1);
			draw_sprite_stretched_add(THEME.box_r2, 0, x, y, w, h, COLORS._main_icon, pre * .2);
			draw_sprite_stretched_add(THEME.box_r2, 1, x, y, w, h, COLORS._main_icon, .2 + .3 * hov);
		}
		
		if(hov && mouse_lpress(focus)) {
			if(input_junc && output_junc) {
				if(input_junc.type == VALUE_TYPE.trigger)
					input_junc.setValue(true);
				
				if(action_junc) {
					var _val = input_junc.getValue();
					action_junc.setValue(_val);
				}
				Render();
				
				var _res = output_junc.getValue();
				input_junc.setValue(_res);
			}
			
			if(isSetValue) input_junc.setValue(setValue);
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
		
		_m.isSetValue = isSetValue;
		_m.setValue   = setValue;
		return _m;
	}
	
	static doDeserialize = function(_m) { 
		bind_input.deserialize(_m.bind);
		bind_action.deserialize(_m.actn);
		bind_output.deserialize(_m.acto);
		
		if(has(_m, "bg"))    bg_output.deserialize(_m.bg);
		if(has(_m, "hover")) hover_output.deserialize(_m.hover);
		if(has(_m, "press")) press_output.deserialize(_m.press);
		
		isSetValue = _m[$ "isSetValue"] ?? isSetValue;
		setValue   = _m[$ "setValue"]   ?? setValue;
		return self;
	}
}