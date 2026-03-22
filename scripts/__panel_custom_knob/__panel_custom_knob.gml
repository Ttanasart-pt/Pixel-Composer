function Panel_Custom_Knob(_data) : Panel_Custom_Element(_data) constructor {
	type = "knob";
	name = "Knob";
	icon = THEME.panel_icon_element_knob;
	modifyContent = false;
	
	bind_input = new JuncLister(data, "Input", CONNECT_TYPE.input);
	
	bg_output    = new JuncLister(data, "Idle",   CONNECT_TYPE.output);
	hover_output = new JuncLister(data, "Hover",  CONNECT_TYPE.output);
	press_output = new JuncLister(data, "Press",  CONNECT_TYPE.output);
	
	style = 1;
	color = COLORS._main_icon_light;
	vstep = 0;
	drawValue = false;
	
	rotate_surf = true;
	dragging  = false;
	dragg_ss  = 0;
	dragg_mx  = 0;
	dragg_my  = 0;
	rotator_m = 0;
	__p = [0,0];
	
	array_append(editors, [
		[ "Value Binding", false ], 
		bind_input,
		
		[ "Knob", false ], 
		Simple_Editor("Slide Step",  textBox_Number( function(v) /*=>*/ { vstep = v; } ), function() /*=>*/ {return vstep}, function(v) /*=>*/ { vstep = v; }), 
		
		[ "Display", false ], 
		Simple_Editor("Style", new scrollBox( [ "Blob", "Flat" ], function(t) /*=>*/ { style = t; } ), function() /*=>*/ {return style}, function(t) /*=>*/ { style = t; }), 
		Simple_Editor("Color", new buttonColor(function(c) /*=>*/ { color = c; } ).hideAlpha(), function() /*=>*/ {return color}, function(t) /*=>*/ { color = t; }), 
		Simple_Editor("Draw Value", new checkBox(function() /*=>*/ { drawValue = !drawValue; } ), function() /*=>*/ {return drawValue}, function(v) /*=>*/ { drawValue = v; }), 
		
		[ "Textures", false ], 
		bg_output,
		hover_output,
		press_output,
		Simple_Editor("Rotate Surface", new checkBox(function() /*=>*/ { rotate_surf = !rotate_surf; } ), function() /*=>*/ {return rotate_surf}, function(v) /*=>*/ { rotate_surf = v; }), 
	]);
	
	////- Draw
	
	static draw = function(panel, _m) {
		input_junc = bind_input.getJunction();
		var hov = elementHover && point_in_rectangle(_m[0], _m[1], x, y, x + w, y + h);
		var pre = (hov && mouse_lclick(focus)) || dragging;
		
		var r  = min(w, h);
		var xc = x + w/2;
		var yc = y + h/2;
		
		var x0 = xc - r/2; 
		var y0 = yc - r/2;
		
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
		
		var _currRad = degtorad(_currVal);
		var _bg_junc = bg_output.getJunction();
		if(_bg_junc) {
			var _dat = undefined;
			var _prs_junc = press_output.getJunction();
			var _hov_junc = hover_output.getJunction();
			
			     if(pre && _prs_junc) _dat = _prs_junc.showValue();
			else if(hov && _hov_junc) _dat = _hov_junc.showValue();
			else                      _dat = _bg_junc.showValue();
			
			if(is_surface(_dat)) {
				var sw = surface_get_width_safe(_dat);
				var sh = surface_get_height_safe(_dat);
				var ss = min(w / sw, h / sh);
				var ssw = sw * ss;
				var ssh = sh * ss;
				
				if(rotate_surf) {
					__p = point_rotate(xc - ssw/2, yc - ssh/2, xc, yc, _currVal, __p);
					draw_surface_ext_safe(_dat, __p[0], __p[1], ss, ss, _currVal);
					
				} else
					draw_surface_ext_safe(_dat, xc - ssw/2, yc - ssh/2, ss, ss);
			}
			
		} else if(style == 0) {
			var c0 = colorMultiply(dragging? c_white : CDEF.main_mdwhite, color);
			var c1 = colorMultiply(CDEF.main_dkgrey, color);
		
			shader_set(sh_ui_rotator);
				shader_set_c( "c0",        c0       );
				shader_set_c( "c1",        c1       );
				shader_set_f( "angle",     _currRad );
				shader_set_f( "mouse",     (_m[0] - x0) / r, (_m[1] - y0) / r         );
				shader_set_f( "mouseProg", animation_curve_eval(ac_ripple, rotator_m) );
				shader_set_2( "radius",    [ degtorad(0), degtorad(360) ]             );
				
				draw_sprite_stretched(s_fx_pixel, 0, x0, y0, r, r);
			shader_reset();
			
		} else if(style == 1) {
			var c0 = colorMultiply(hov? c_white : CDEF.main_mdwhite, color);
			
			shader_set(sh_widget_rotator);
				shader_set_c( "color", c0       );
				shader_set_f( "side",  r        );
				shader_set_f( "angle", _currRad );
			
				draw_sprite_stretched(s_fx_pixel, 0, x0, y0, r, r);
			shader_reset();
		}
		
		if(drawValue) {
			draw_set_text(f_sdf, fa_center, fa_center, color);
			var str = string_real(_currVal, 999, 3);
			var tbs = min(r / string_width(str), r / string_height(str)) * .4;
			draw_text_transformed(xc, yc, str, tbs, tbs, 0);
		}
		
		if(dragging) {
			rotator_m = lerp_float(rotator_m, 1, 4);
			var _dir0 = point_direction(xc, yc, dragg_mx, dragg_my);
			var _dir1 = point_direction(xc, yc, _m[0], _m[1]);
			
			var delt  = angle_difference(_dir1, _dir0);
			dragg_ss += delt;
			dragg_mx  = _m[0];
			dragg_my  = _m[1];
			
			var val = dragg_ss;
			if(vstep != 0) val = value_snap(val, vstep);
			
			if(input_junc.setValue(val)) UNDO_HOLDING = true;
				
			if(mouse_lrelease()) {
				dragging = false;
				UNDO_HOLDING = false;
			}
			
		} else 
			rotator_m = lerp_float(rotator_m, 0, 5);
	}
	
	////- Serialize
	
	static doSerialize = function(_m) {
		_m.bind  = bind_input.serialize(_m);
		_m.bg    = bg_output.serialize(_m);
		_m.hover = hover_output.serialize(_m);
		_m.press = press_output.serialize(_m);
		
		_m.style = style;
		_m.color = color;
		_m.vstep = vstep;
		_m.drawValue   = drawValue;
		_m.rotate_surf = rotate_surf;
		return _m;
	}
	
	static doDeserialize = function(_m) { 
		bind_input.deserialize(_m.bind);
		
		if(has(_m, "bg"))    bg_output.deserialize(_m.bg);
		if(has(_m, "hover")) hover_output.deserialize(_m.hover);
		if(has(_m, "press")) press_output.deserialize(_m.press);
		
		style = _m[$ "style"] ?? style;
		color = _m[$ "color"] ?? color;
		vstep = _m[$ "vstep"] ?? vstep;
		drawValue   = _m[$ "drawValue"]   ?? drawValue;
		rotate_surf = _m[$ "rotate_surf"] ?? rotate_surf;
		return self;
	}
}