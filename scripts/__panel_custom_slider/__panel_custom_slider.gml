function Panel_Custom_Slider(_data) : Panel_Custom_Element(_data) constructor {
	type = "slider";
	name = "Slider";
	icon = THEME.panel_icon_element_slider;
	
	bind_input  = new JuncLister(data, "Input",   CONNECT_TYPE.input);
	slot_output = new JuncLister(data, "Slot BG", CONNECT_TYPE.output);
	
	knob_output  = new JuncLister(data, "Knob BG", CONNECT_TYPE.output);
	hover_output = new JuncLister(data, "Hover",   CONNECT_TYPE.output);
	press_output = new JuncLister(data, "Press",   CONNECT_TYPE.output);
	
	slot_pbox = new __pbBox();
	slot_pbox.anchor_x_type = PB_AXIS_ANCHOR.bounded;
	slot_pbox.anchor_y_type = PB_AXIS_ANCHOR.bounded;
	slot_bbox = [0,0,1,1];
	
	knob_pbox = new __pbBox();
	knob_pbox.anchor_x_type = PB_AXIS_ANCHOR.center;
	knob_pbox.anchor_y_type = PB_AXIS_ANCHOR.center;
	knob_pbox.anchor_w = 16; knob_pbox.anchor_w_fract = false;
	knob_pbox.anchor_h =  1; knob_pbox.anchor_h_fract =  true;
	knob_bbox = [0,0,1,1];
	
	style  = 1;
	color  = COLORS._main_icon_light;
	direct = 0;
	range  = [0,1];
	
	dragging = false;
	dragg_ss = 0;
	dragg_mm = 0;
	slider_m = 0;
	
	array_append(editors, [
		[ "Value Binding", false ], 
		bind_input,
		
		[ "Sliding", false ], 
		Simple_Editor("Axis", new scrollBox( [ "Horizontal", "Vertical" ], function(t) /*=>*/ { direct = t; } ), function() /*=>*/ {return direct}, function(t) /*=>*/ { direct = t; }), 
		Simple_Editor("Slide Range", new rangeBox( function(v,i) /*=>*/ { range[i] = v; } ), function() /*=>*/ {return range}, function(v) /*=>*/ { range = v; }), 
		
		[ "Display", false ], 
		Simple_Editor("Style", new scrollBox( [ "Blob", "Flat" ], function(t) /*=>*/ { style = t; } ), function() /*=>*/ {return style}, function(t) /*=>*/ { style = t; }), 
		Simple_Editor("Color", new buttonColor(function(c) /*=>*/ { color = c; } ).hideAlpha(), function() /*=>*/ {return color}, function(t) /*=>*/ { color = t; }), 
		
		[ "Slot", false ], 
		Simple_Editor("Position", new pbBoxBox(), function() /*=>*/ {return slot_pbox}, function(v) /*=>*/ { slot_pbox = v; }), 
		slot_output,
		
		[ "Knob", false ], 
		Simple_Editor("Position", new pbBoxBox(), function() /*=>*/ {return knob_pbox}, function(v) /*=>*/ { knob_pbox = v; }), 
		knob_output,
		hover_output,
		press_output,
	]);
	
	////- Draw
	
	static draw = function(panel, _m) {
		input_junc = bind_input.getJunction();
		
		slot_bbox = slot_pbox.setBase(bbox).getBBOX(slot_bbox);
		var sx0 = slot_bbox[0];
		var sy0 = slot_bbox[1];
		var sx1 = slot_bbox[2];
		var sy1 = slot_bbox[3];
		var sw  = sx1 - sx0;
		var sh  = sy1 - sy0;
		
		var _currVal = 0;
		var _currRan = 0;
		var hov = elementHover;
		
		if(input_junc) {
			_currVal = toNumber(input_junc.showValue());
			_currRan = (_currVal - range[0]) / (range[1] - range[0]);
			_currRan = clamp(_currRan, 0, 1);
		}
		
		if(style == 0) {
			var c0 = colorMultiply(dragging? c_white : CDEF.main_mdwhite, color);
			var c1 = colorMultiply(CDEF.main_dkgrey, color);
			
			shader_set(sh_ui_slider);
				shader_set_c( "c0",        c0      );
				shader_set_c( "c1",        c1      );
				shader_set_2( "dimension", [sw,sh] );
				shader_set_f( "mouseProg", animation_curve_eval(ac_ripple, slider_m) );
				shader_set_f( "prog",      clamp(_currRan, 0.1, 0.9) );
				
				draw_sprite_stretched(s_fx_pixel, 0, sx0, sy0, sw, sh);
			shader_reset();
			
		} else {
			var _slot_junc = slot_output.getJunction();
			if(_slot_junc) {
				var _dat = _slot_junc.showValue();
				if(is_surface(_dat)) draw_surface_stretched_safe(_dat, sx0, sy0, sw, sh);
				
			} else
				draw_sprite_stretched_ext(THEME.box_r2, 0, sx0, sy0, sw, sh, COLORS._main_icon_dark, 1);
			
			knob_bbox = knob_pbox.setBase(bbox).getBBOX(knob_bbox);
			if(direct == 0) {
				var kw  = knob_bbox[2] - knob_bbox[0];
				var kx0 = slot_bbox[0] + kw / 2;
				var kx1 = slot_bbox[2] - kw / 2;
				
				var cx = lerp(kx0, kx1, _currRan);
				knob_bbox[0] = cx - kw / 2;
				knob_bbox[2] = cx + kw / 2;
				
			} else {
				var kh  = knob_bbox[3] - knob_bbox[1];
				var ky0 = slot_bbox[1] + kh / 2;
				var ky1 = slot_bbox[3] - kh / 2;
				
				var cy = lerp(ky0, ky1, _currRan);
				knob_bbox[1] = cy - kh / 2;
				knob_bbox[3] = cy + kh / 2;
				
			}
			
			var kx0 = knob_bbox[0];
			var ky0 = knob_bbox[1];
			var kx1 = knob_bbox[2];
			var ky1 = knob_bbox[3];
			var kw  = kx1 - kx0;
			var kh  = ky1 - ky0;
			
			hov = elementHover && point_in_rectangle(_m[0], _m[1], kx0, ky0, kx1, ky1);
			var pre = (hov && mouse_lclick(focus)) || dragging;
			
			var _knob_junc = knob_output.getJunction();
			if(_knob_junc) {
				var _dat = undefined;
				var _prs_junc = press_output.getJunction();
				var _hov_junc = hover_output.getJunction();
				
				     if(pre && _prs_junc) _dat = _prs_junc.showValue();
				else if(hov && _hov_junc) _dat = _hov_junc.showValue();
				else                      _dat = _knob_junc.showValue();
				
				if(is_surface(_dat)) draw_surface_stretched_safe(_dat, kx0, ky0, kw, kh);
				
			} else {
				draw_sprite_stretched_ext(THEME.box_r2, 0, kx0, ky0, kw, kh, COLORS._main_icon, 1);
				draw_sprite_stretched_add(THEME.box_r2, 1, kx0, ky0, kw, kh, COLORS._main_icon, .2 + .3 * hov);
			}
			
		}
		
		if(input_junc && hov && mouse_lpress(focus)) {
			dragging = true;
			dragg_ss = _currVal;
			dragg_mm = direct == 0? _m[0] : _m[1];
		}
		
		if(dragging) {
			slider_m = lerp_float(slider_m, 1, 4);
			var val;
			
			if(direct == 0) val = dragg_ss + (_m[0] - dragg_mm) / sw * (range[1] - range[0]);
			else            val = dragg_ss + (_m[1] - dragg_mm) / sh * (range[1] - range[0]);
			    
		    val = clamp(val, range[0], range[1]);
			if(input_junc && input_junc.setValue(val))
				UNDO_HOLDING = true;
			
			if(mouse_lrelease()) {
				dragging     = false;
				UNDO_HOLDING = false;
			}
			
		} else slider_m = lerp_float(slider_m, 0, 5);
	}
	
	////- Serialize
	
	static doSerialize = function(_m) {
		_m.style  = style;
		_m.color  = color;
		_m.direct = direct;
		_m.range  = range;
		
		_m.bind  = bind_input.serialize(_m);
		_m.slot  = slot_output.serialize(_m);
		_m.knob  = knob_output.serialize(_m);
		_m.hover = hover_output.serialize(_m);
		_m.press = press_output.serialize(_m);
		
		_m.slot_box = slot_pbox.serialize().uiScale(true);
		_m.knob_box = knob_pbox.serialize().uiScale(true);
		return _m;
	}
	
	static doDeserialize = function(_m) { 
		style  = _m[$ "style"]  ?? style;
		color  = _m[$ "color"]  ?? color;
		direct = _m[$ "direct"] ?? direct;
		range  = _m[$ "range"]  ?? range;
		
		bind_input.deserialize(_m.bind);
		if(has(_m, "slot"))  slot_output.deserialize(_m.slot);
		if(has(_m, "knob"))  knob_output.deserialize(_m.knob);
		if(has(_m, "hover")) hover_output.deserialize(_m.hover);
		if(has(_m, "press")) press_output.deserialize(_m.press);
		
		if(has(_m, "slot_box")) slot_pbox.deserialize(_m.slot_box).uiScale(false);
		if(has(_m, "knob_box")) knob_pbox.deserialize(_m.knob_box).uiScale(false);
		
		return self;
	}
}