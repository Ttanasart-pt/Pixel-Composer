function Node_Number(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Number";
	color = COLORS.node_blend_number;
	
	setDimension(96, 32 + 24 * 1);
	
	// wd_slider = slider(0, 1, 0.01, function(val) { inputs[0].setValue(val); } );
	
	slider_value    = -1;
	slider_surface  = -1;
	slider_dragging = false;
	slider_mx = 0;
	slider_sx = 0;
	slider_m  = 0;
	
	rotator_surface  = -1;
	rotator_dragging = false;
	rotator_s = 0;
	rotator_p = 0;
	rotator_m = 0;
	
	newInput(0, nodeValue_Float("Value", self, 0))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Bool("Integer", self, false));
	
	newInput(2, nodeValue_Enum_Scroll("Display", self, 0, { data: [ "Number", "Slider", "Rotator", "Increment" ], update_hover: false }));
	
	newInput(3, nodeValue_Range("Range", self, [ 0, 1 ]));
	
	newInput(4, nodeValue_Float("Step", self, 0.01));
	
	newInput(5, nodeValue_Bool("Clamp to range", self, true));
	
	newInput(6, nodeValue_Enum_Button("Style", self, 0, { data: [ "Blob", "Flat" ] }));
	
	newOutput(0, nodeValue_Output("Number", self, VALUE_TYPE.float, 0));
	
	input_display_list = [ 0, 1, 
		["Display", false], 2, 6, 3, 4, 5, 
	]
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _val = getInputData(0);
		var _dsp = getInputData(2);
		if(is_array(_val)) return;
		
		if(_dsp == 0 || _dsp == 1) inputs[0].display_type = VALUE_DISPLAY._default;
		else if(_dsp == 2)	       inputs[0].display_type = VALUE_DISPLAY.rotation;
			
		inputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[0].display_type = VALUE_DISPLAY._default;
	}
	
	static setType = function() {
		var int  = getInputData(1);
		var disp = getInputData(2);
		var styl = getInputData(6);
		
		var _ww = 96, _hh = 56;
		
		switch(disp) {
			case 0 : 
				inputs[3].setVisible(false);
				inputs[4].setVisible(false);
				inputs[5].setVisible(false);
				inputs[6].setVisible(false);
				break;
				
			case 1 : 
				_ww = 160; 
					 if(styl == 0) _hh = 96;
				else if(styl == 1) _hh = 64;
				
				inputs[3].setVisible(true);
				inputs[4].setVisible(true);
				inputs[5].setVisible(true);
				inputs[6].setVisible(true);
				break;
				
			case 2 : 
				_ww = 128; _hh = 128;
				
				inputs[3].setVisible(false);
				inputs[4].setVisible(false);
				inputs[5].setVisible(false);
				inputs[6].setVisible(true);
				break;
				
			case 3 : 
				_ww = 160; _hh = 64;
				
				inputs[3].setVisible(true);
				inputs[4].setVisible(true);
				inputs[5].setVisible(true);
				inputs[6].setVisible(true);
				break;
				
		}
		
		setDimension(_ww, _hh);
		
		inputs[0].setType(int? VALUE_TYPE.integer : VALUE_TYPE.float);
		outputs[0].setType(int? VALUE_TYPE.integer : VALUE_TYPE.float);
	}
	
	static processNumber = function(_val, _int) { 
		if(is_string(_val))  return _int? round(toNumber(_val)) : toNumber(_val);
		if(is_numeric(_val)) return _int? round(_val) : _val;
		
		if(is_array(_val)) {
			for (var i = 0, n = array_length(_val); i < n; i++)
				_val[i] = processNumber(_val[i], _int);
		}
		
		return _val;
	}
	
	static update = function() {
		setType();
		
		var _dat = getInputData(0);
		var _int = getInputData(1);
		var _res = processNumber(_dat, _int);
		
		outputs[0].setValue(_res);
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var raw  = getInputData(0);
		var _int = getInputData(1);
		var disp = getInputData(2);
		var rang = getInputData(3);
		var stp  = getInputData(4);
		var cmp  = getInputData(5);
		var sty  = getInputData(6);
		var _col = getColor();
		
		var val  = outputs[0].getValue();
		
		var bbox = drawGetBbox(xx, yy, _s);
		if(disp == 0 || inputs[0].value_from != noone) {
			draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
			draw_text_bbox(bbox, string_real(val));
			return;
		}
		
		var _minn = rang[0];
		var _maxx = rang[1];
				
		switch(disp) {
			case 1 :
				var _hov  = _hover;
				
				if(sty == 0) {
					slider_value = slider_value == -1? raw : lerp_float(slider_value, raw, 2.5);
					var _prog = clamp((slider_value - _minn) / (_maxx - _minn), 0., 1.);
					
					bbox = drawGetBbox(xx, yy, _s, false);
					bbox.fromPoints(bbox.x0, bbox.y0 + 16 * _s, bbox.x1, bbox.y1);
					
					draw_set_text(f_sdf, fa_center, fa_center, _col);
					draw_text_transformed(bbox.xc, bbox.y0 + 16 * _s, string_real(val), _s * 0.5, _s * 0.5, 0);
				
					var sl_w = bbox.w - 8 * _s;
					var sl_h = _s * 40;
					
					var sl_x0 = bbox.x0 + 4 * _s;
					var sl_x1 = sl_x0 + sl_w;
					var sl_y0 = (bbox.y0 + (24 * _s) + bbox.y1) / 2 - sl_h / 2;
					var sl_y1 = sl_y0 + sl_h;
					var _hov  = _hover && point_in_rectangle(_mx, _my, sl_x0, sl_y0, sl_x1, sl_y1);
					
					var c0   = (_hov || slider_dragging)? colorMultiply(CDEF.main_white, _col) : colorMultiply(CDEF.main_grey, _col);
					var c1   = colorMultiply(CDEF.main_dkgrey, _col);
					
					slider_surface = surface_verify(slider_surface, sl_w, sl_h);
					
					surface_set_shader(slider_surface, sh_ui_slider);
						shader_set_color("c0", c0);
						shader_set_color("c1", c1);
						shader_set_dim("dimension", slider_surface);
						shader_set_f("mouseProg", animation_curve_eval(ac_ripple, slider_m));
						shader_set_f("prog", clamp(_prog, 0.1, 0.9));
						
						draw_sprite_stretched(s_fx_pixel, 0, 0, 0, sl_w, sl_h);
					surface_reset_shader();
					
					draw_surface(slider_surface, sl_x0, sl_y0);
					
				} else if(sty == 1) {
					slider_value = raw;
					var _prog = clamp((slider_value - _minn) / (_maxx - _minn), 0., 1.);
					
					var sl_w = bbox.w - 8 * _s;
					var sl_h = bbox.h - 8 * _s;
					
					var sl_x0 = bbox.x0 + 4 * _s;
					var sl_x1 = bbox.x1 - 4 * _s;
					var sl_y0 = bbox.y0 + 4 * _s;
					var sl_y1 = bbox.y1 - 4 * _s;
					var _hov  = _hover && point_in_rectangle(_mx, _my, sl_x0, sl_y0, sl_x1, sl_y1);
					
					draw_sprite_stretched_ext(THEME.textbox, 3,    sl_x0, sl_y0, sl_w,         sl_h + 1, _col, 1);
					draw_sprite_stretched_ext(THEME.textbox, 4,    sl_x0, sl_y0, sl_w * _prog, sl_h + 1, _col, 1);
					draw_sprite_stretched_ext(THEME.textbox, _hov || slider_dragging, sl_x0, sl_y0, sl_w, sl_h + 1, _col, 1);
					
					draw_set_text(f_sdf, fa_center, fa_center, _col);
					draw_text_transformed(bbox.xc, bbox.yc + 2, string_real(val), _s * 0.5, _s * 0.5, 0);
					
				}
				
				if(slider_dragging) {
					slider_m = lerp_float(slider_m, 1, 4);
					
					var _valM = (_mx - sl_x0) / (sl_x1 - sl_x0);
					var _valL = lerp(_minn, _maxx, _valM);
					    _valL = value_snap(_valL, stp);
					if(cmp) _valL = clamp(_valL, _minn, _maxx);
					
					if(inputs[0].setValue(_valL))
						UNDO_HOLDING = true;
					
					if(mouse_release(mb_left)) {
						slider_dragging = false;
						UNDO_HOLDING    = false;
					}
				} else 
					slider_m = lerp_float(slider_m, 0, 5);
				
				if(_hov) {
					if(mouse_press(mb_left, _focus) && is_real(raw)) {
						slider_dragging = true;
						slider_mx = _mx;
						slider_sx = raw;
					}
					
					draggable = false;
				}
				
				break;
				
			case 2 :
				var _ss  = min(bbox.w, bbox.h);
				var _dst = point_distance(_mx, _my, bbox.xc, bbox.yc);
				var _x0  = bbox.xc - _ss / 2;
				var _y0  = bbox.yc - _ss / 2;
				
				if(sty == 0) {
					var c0   = (draggable && !rotator_dragging)? colorMultiply(CDEF.main_grey, _col) : colorMultiply(CDEF.main_white, _col);
					var c1   = colorMultiply(CDEF.main_dkgrey, _col);
				
					rotator_surface = surface_verify(rotator_surface, _ss, _ss);
					
					surface_set_shader(rotator_surface, sh_ui_rotator);
						shader_set_color("c0", c0);
						shader_set_color("c1", c1);
						shader_set_f("angle", degtorad(raw));
						shader_set_f("mouse", (_mx - _x0) / _ss, (_my - _y0) / _ss);
						shader_set_f("mouseProg", animation_curve_eval(ac_ripple, rotator_m));
						
						draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _ss, _ss);
					surface_reset_shader();
					
					draw_surface(rotator_surface, _x0, _y0);
					
				} else if(sty == 1) {
					var c0   = (draggable && !rotator_dragging)? colorMultiply(CDEF.main_grey, _col) : colorMultiply(CDEF.main_white, _col);
					var c1   = colorMultiply(merge_color(CDEF.main_grey, CDEF.main_dkgrey, .5), _col);
				
					var _r = _ss / 2 - 10 * _s;
					draw_circle_ui(bbox.xc, bbox.yc, _r, .04, cola(c1));
					
					var _knx =  bbox.xc + lengthdir_x(_r - 2 * _s, raw);
					var _kny =  bbox.yc + lengthdir_y(_r - 2 * _s, raw);
					
					draw_circle_ui(_knx, _kny, 8 * _s, 0, cola(c0));
				}
				
				if(rotator_dragging) {
					rotator_m = lerp_float(rotator_m, 1, 4);
					var dir = point_direction(bbox.xc, bbox.yc, _mx, _my);
					var dx  = angle_difference(dir, rotator_p);
					rotator_p = dir;
					
					if(inputs[0].setValue(raw + dx))
						UNDO_HOLDING = true;
					
					if(mouse_release(mb_left)) {
						rotator_dragging = false;
						UNDO_HOLDING     = false;
					}
				} else 
					rotator_m = lerp_float(rotator_m, 0, 5);
				
				if(_hover && point_in_circle(_mx, _my, bbox.xc, bbox.yc, _ss / 2)) {
					if(mouse_press(mb_left, _focus) && is_real(raw)) {
						rotator_dragging = true;
						rotator_s = raw;
						rotator_p = point_direction(bbox.xc, bbox.yc, _mx, _my);
					}
					
					draggable = false;
				}
				
				draw_set_text(f_sdf, fa_center, fa_center, _col);
				draw_text_transformed(bbox.xc, bbox.yc, string_real(val, 999, 3), _s * .5, _s * .5, 0);
				break;
				
			case 3 :
				var bw = 32 * _s;
				var bh = bbox.h  - 8 * _s;
				var bx = bbox.x0 + 4 * _s;
				var by = bbox.y0 + 4 * _s;
				var cc = colorMultiply(CDEF.main_white, _col);
				
				var b = buttonInstant(THEME.button_def, bx, by, bw, bh, [ _mx, _my ], _focus, _hover, "", THEME.minus, 0, COLORS._main_value_negative, 1, .75 * _s, cc);
				if(b) draggable = false;
				if(b == 2) {
					val -= stp;
					if(cmp) val = clamp(val, _minn, _maxx);
					inputs[0].setValue(val);
				}
				
				var bx = bbox.x1 - 4 * _s - bw;
				var b = buttonInstant(THEME.button_def, bx, by, bw, bh, [ _mx, _my ], _focus, _hover, "", THEME.add, 0, COLORS._main_value_positive, 1, .75 * _s, cc);
				if(b) draggable = false;
				if(b == 2) {
					val += stp;
					if(cmp) val = clamp(val, _minn, _maxx);
					inputs[0].setValue(val);
				}
				
				draw_set_text(f_sdf, fa_center, fa_center, _col);
				draw_text_transformed(bbox.xc, bbox.yc + 2, string_real(val), _s * 0.5, _s * 0.5, 0);
				break;
				
		}
	}

}