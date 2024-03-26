function Node_Number(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor { #region
	name  = "Number";
	color = COLORS.node_blend_number;
	
	w				= 96;
	min_h			= 32 + 24 * 1;
	draw_padding	= 4;
	display_output	= 0;
	
	wd_slider = new slider(0, 1, 0.01, function(val) { inputs[| 0].setValue(val); } );
	wd_slider.spr   = THEME.node_slider;
	
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
	
	inputs[| 0] = nodeValue("Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Integer", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 2] = nodeValue("Display", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, { data: [ "Number", "Slider", "Rotator" ], update_hover: false });
	
	inputs[| 3] = nodeValue("Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 4] = nodeValue("Step", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.01)
	
	inputs[| 5] = nodeValue("Clamp to range", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
	
	outputs[| 0] = nodeValue("Number", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var __ax = getInputData(0);
		if(is_array(__ax)) return;
		
		inputs[| 0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	} #endregion
	
	static step = function() { #region
		var int  = getInputData(1);
		var disp = getInputData(2);
		
		var _h = min_h;
		
		w	  = 96;	
		min_h = 56; 
		
		switch(disp) {
			case 0 : 
				inputs[| 3].setVisible(false);
				inputs[| 4].setVisible(false);
				inputs[| 5].setVisible(false);
				break;
			case 1 : 
				if(inputs[| 0].isLeaf()) {
					w	  = 160;
					min_h = 96;
				}
				inputs[| 3].setVisible(true);
				inputs[| 4].setVisible(true);
				inputs[| 5].setVisible(true);
				break;
			case 2 : 
				if(inputs[| 0].isLeaf()) {
					w	  = 128;
					min_h = 128;		 
				}
				inputs[| 3].setVisible(false);
				inputs[| 4].setVisible(false);
				inputs[| 5].setVisible(false);
				break;
		}
		
		if(_h != min_h) setHeight();
		
		for( var i = 0; i < 1; i++ ) {
			inputs[| i].setType(int? VALUE_TYPE.integer : VALUE_TYPE.float);
			inputs[| i].editWidget.setSlidable(int? 0.1 : 0.01);
		}
		
		outputs[| 0].setType(int? VALUE_TYPE.integer : VALUE_TYPE.float);
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _dat = _data[0];
		var _int = _data[1];
		
		if(is_array(_dat)) return _dat;
		if(!is_numeric(_dat)) _dat = real(_dat);
		if(_int) _dat = round(_dat);
		
		display_output = _dat;
		return _dat;
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		var val  = getInputData(0);
		var _int = getInputData(1);
		var disp = getInputData(2);
		var rang = getInputData(3);
		var stp  = getInputData(4);
		var cmp  = getInputData(5);
		var _col = getColor();
		
		if(disp == 0 || inputs[| 0].value_from != noone || bbox.h < line_get_height(f_p2)) {
			draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
			draw_text_bbox(bbox, string(val));
			return;
		}
		
		switch(disp) {
			case 1 : #region
				draw_set_text(f_sdf, fa_center, fa_center, _col);
				draw_text_transformed(bbox.xc, bbox.y0 + 16 * _s, _int? round(val) : val, _s * 0.5, _s * 0.5, 0);
				
				var sl_w = bbox.w - 8 * _s;
				var sl_h = _s * 40;
				
				var sl_x0 = bbox.x0 + 4 * _s;
				var sl_x1 = sl_x0 + sl_w;
				var sl_y0 = (bbox.y0 + (24 * _s) + bbox.y1) / 2 - sl_h / 2;
				var sl_y1 = sl_y0 + sl_h;
				
				var c0   = (draggable && !slider_dragging)? colorMultiply(CDEF.main_grey, _col) : colorMultiply(CDEF.main_white, _col);
				var c1   = colorMultiply(CDEF.main_dkgrey, _col);
				
				var _minn = rang[0];
				var _maxx = rang[1];
					
				slider_surface = surface_verify(slider_surface, sl_w, sl_h);
				slider_value   = slider_value == -1? val : lerp_float(slider_value, val, 2.5);
				
				surface_set_shader(slider_surface, sh_ui_slider);
					shader_set_color("c0", c0);
					shader_set_color("c1", c1);
					shader_set_dim("dimension", slider_surface);
					shader_set_f("mouseProg", animation_curve_eval(ac_ripple, slider_m));
					shader_set_f("prog", clamp((slider_value - _minn) / (_maxx - _minn), 0.1, 0.9));
					
					draw_sprite_stretched(s_fx_pixel, 0, 0, 0, sl_w, sl_h);
				surface_reset_shader();
				
				draw_surface(slider_surface, sl_x0, sl_y0);
				
				if(slider_dragging) {
					slider_m = lerp_float(slider_m, 1, 4);
					
					var _valM = (_mx - sl_x0) / (sl_x1 - sl_x0);
					var _valL = lerp(_minn, _maxx, _valM);
					    _valL = value_snap(_valL, stp);
					if(cmp) _valL = clamp(_valL, _minn, _maxx);
					
					if(inputs[| 0].setValue(_valL))
						UNDO_HOLDING = true;
					
					if(mouse_release(mb_left)) {
						slider_dragging = false;
						UNDO_HOLDING    = false;
					}
				} else 
					slider_m = lerp_float(slider_m, 0, 5);
				
				draggable = true;
				if(_hover && point_in_rectangle(_mx, _my, sl_x0, sl_y0, sl_x1, sl_y1)) {
					if(mouse_press(mb_left, _focus) && is_real(val)) {
						slider_dragging = true;
						slider_mx = _mx;
						slider_sx = val;
					}
					
					draggable = false;
				}
				
				break; #endregion
			case 2 : #region
				var _ss  = min(bbox.w, bbox.h);
				var c0   = (draggable && !rotator_dragging)? colorMultiply(CDEF.main_grey, _col) : colorMultiply(CDEF.main_white, _col);
				var c1   = colorMultiply(CDEF.main_dkgrey, _col);
				var _dst = point_distance(_mx, _my, bbox.xc, bbox.yc);
				var _x0  = bbox.xc - _ss / 2;
				var _y0  = bbox.yc - _ss / 2;
				
				rotator_surface = surface_verify(rotator_surface, _ss, _ss);
				
				surface_set_shader(rotator_surface, sh_ui_rotator);
					shader_set_color("c0", c0);
					shader_set_color("c1", c1);
					shader_set_f("angle", degtorad(val));
					shader_set_f("mouse", (_mx - _x0) / _ss, (_my - _y0) / _ss);
					shader_set_f("mouseProg", animation_curve_eval(ac_ripple, rotator_m));
					
					draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _ss, _ss);
				surface_reset_shader();
				
				draw_surface(rotator_surface, _x0, _y0);
				
				if(rotator_dragging) {
					rotator_m = lerp_float(rotator_m, 1, 4);
					var dir = point_direction(bbox.xc, bbox.yc, _mx, _my);
					var dx  = angle_difference(dir, rotator_p);
					rotator_p = dir;
					
					if(inputs[| 0].setValue(val + dx))
						UNDO_HOLDING = true;
					
					if(mouse_release(mb_left)) {
						rotator_dragging = false;
						UNDO_HOLDING     = false;
					}
				} else 
					rotator_m = lerp_float(rotator_m, 0, 5);
				
				draggable = true;
				if(_hover && point_in_circle(_mx, _my, bbox.xc, bbox.yc, _ss / 2)) {
					if(mouse_press(mb_left, _focus) && is_real(val)) {
						rotator_dragging = true;
						rotator_s = val;
						rotator_p = point_direction(bbox.xc, bbox.yc, _mx, _my);
					}
					
					draggable = false;
				}
				
				draw_set_text(f_sdf, fa_center, fa_center, colorMultiply(CDEF.main_white, _col));
				draw_text_transformed(bbox.xc, bbox.yc, _int? round(val) : string_format(val, -1, 2), _s * .5, _s * .5, 0);
				break; #endregion
		}
	} #endregion
} #endregion