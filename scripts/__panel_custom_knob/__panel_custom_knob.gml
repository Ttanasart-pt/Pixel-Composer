function Panel_Custom_Knob() : Panel_Custom_Element() constructor {
	type = "knob";
	name = "Knob";
	icon = THEME.panel_icon_element_knob;
	modifyContent = false;
	
	bind_input = new JuncLister("Input", CONNECT_TYPE.input);
	
	bg_output    = new JuncLister("Idle",   CONNECT_TYPE.output);
	hover_output = new JuncLister("Hover",  CONNECT_TYPE.output);
	press_output = new JuncLister("Press",  CONNECT_TYPE.output);
	
	rotate_surf = true;
	
	dragging = false;
	dragg_ss = 0;
	dragg_mx = 0;
	dragg_my = 0;
	__p = [0,0];
	
	array_append(editors, [
		[ "Value Binding", false ], 
		bind_input,
		
		[ "Textures", false ], 
		bg_output,
		hover_output,
		press_output,
		Simple_Editor("Rotate Surface", new checkBox( function() /*=>*/ { rotate_surf = !rotate_surf; } ), function() /*=>*/ {return rotate_surf}, function(v) /*=>*/ { rotate_surf = v; }), 
	]);
	
	////- Draw
	
	static draw = function(panel, _m) {
		input_junc = bind_input.getJunction();
		var hov = elementHover && point_in_rectangle(_m[0], _m[1], x, y, x + w, y + h);
		var pre = (hov && mouse_lclick(focus)) || dragging;
		
		var xc = x + w/2;
		var yc = y + h/2;
		
		var r = min(w, h);
		var _currVal = 0;
		
		if(input_junc) {
			_currVal = toNumber(input_junc.showValue());
			
			if(hov && mouse_lpress(focus)) {
				dragging = true;
				dragg_ss = _currVal;
				dragg_mx = _m[0];
				dragg_my = _m[1];
			}
		}
		
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
			
			if(is_surface(_dat)) {
				if(rotate_surf) {
					var sw = surface_get_width_safe(_dat);
					var sh = surface_get_height_safe(_dat);
					
					__p = point_rotate(x, y, xc, yc, _currVal, __p);
					draw_surface_ext_safe(_dat, __p[0], __p[1], w/sw, h/sh, _currVal);
					
				} else
					draw_surface_stretched_safe(_dat, x, y, w, h);
			}
			
		} else {
			shader_set(sh_widget_rotator);
				shader_set_color("color", hov? COLORS._main_icon_light : COLORS._main_icon);
				shader_set_f("side",     r);
				shader_set_f("angle",    degtorad(_currVal));
			
				draw_sprite_stretched(s_fx_pixel, 0, xc - r/2, yc - r/2, r, r);
			shader_reset();
		}
		
		if(dragging) {
			var _dir0 = point_direction(xc, yc, dragg_mx, dragg_my);
			var _dir1 = point_direction(xc, yc, _m[0], _m[1]);
			
			var delt  = angle_difference(_dir1, _dir0);
			dragg_ss += delt;
			dragg_mx  = _m[0];
			dragg_my  = _m[1];
			
			if(input_junc.setValue(dragg_ss)) UNDO_HOLDING = true;
				
			if(mouse_lrelease()) {
				dragging = false;
				UNDO_HOLDING = false;
			}
		}
	}
	
	////- Serialize
	
	static doSerialize = function(_m) {
		_m.bind  = bind_input.serialize(_m);
		_m.bg    = bg_output.serialize(_m);
		_m.hover = hover_output.serialize(_m);
		_m.press = press_output.serialize(_m);
		
		_m.rotate_surf = rotate_surf;
		return _m;
	}
	
	static doDeserialize = function(_m) { 
		bind_input.deserialize(_m.bind);
		
		if(has(_m, "bg"))    bg_output.deserialize(_m.bg);
		if(has(_m, "hover")) hover_output.deserialize(_m.hover);
		if(has(_m, "press")) press_output.deserialize(_m.press);
		
		rotate_surf = _m[$ "rotate_surf"] ?? rotate_surf;
		return self;
	}
}