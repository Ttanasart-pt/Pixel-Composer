enum LIGHT_SHAPE_2D {
	point,
	ellipse,
	line,
	line_asym,
	saber,
	spot,
	flame,
}

function Node_2D_light(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "2D Light";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	typeList = [ 
		new scrollItem("Point",           s_node_2d_light_shape, 0), 
		new scrollItem("Ellipse",         s_node_2d_light_shape, 1), 
		new scrollItem("Line",            s_node_2d_light_shape, 2), 
		new scrollItem("Line asymmetric", s_node_2d_light_shape, 3), 
		new scrollItem("Saber",           s_node_2d_light_shape, 4), 
		new scrollItem("Spot",            s_node_2d_light_shape, 5), 
		new scrollItem("Flame",           s_node_2d_light_shape, 6), 
	];
	
	typeListStr = array_create_ext(array_length(typeList), function(i) /*=>*/ {return typeList[i].name});
	
	static createNewInput = function() {
		var _index = array_length(inputs);
		dynamic_input_inspecting = getInputAmount();
		
		var _val = nodeValue_Enum_Scroll("Light shape", self, 0, typeList);
			_val.options_histories = [ typeListStr,
				{
					cond: function() /*=>*/ {return LOADING_VERSION < 1_18_00_0 && !CLONING},
					list: [ "Point", "Line", "Line asymmetric", "Spot" ]
				}
			];	 
		newInput(_index + 0, _val);
		
		newInput(_index + 1, nodeValue_Vec2("Center", self, [ 16, 16 ]))
			.setUnitRef(function(index) { return getDimension(index); });
		
		newInput(_index + 2, nodeValue_Float("Range", self, 16));
		
		newInput(_index + 3, nodeValue_Float("Intensity", self, 1))
			.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ]});
		
		newInput(_index + 4, nodeValue_Color("Color", self, cola(c_white)));
		
		newInput(_index + 5, nodeValue_Vec2("Start", self, [ 16, 16 ]));
		
		newInput(_index + 6, nodeValue_Vec2("Finish", self, [ 32, 16 ]));
		
		newInput(_index + 7, nodeValue_Int("Sweep", self, 15))
			.setDisplay(VALUE_DISPLAY.slider, { range: [-80, 80, 0.1] });
		
		newInput(_index + 8, nodeValue_Int("Sweep end", self, 0))
			.setDisplay(VALUE_DISPLAY.slider, { range: [-80, 80, 0.1] });
		
		newInput(_index + 9, nodeValue_Int("Banding", self, 0))
			.setDisplay(VALUE_DISPLAY.slider, { range: [0, 16, 0.1] });
		
		newInput(_index + 10, nodeValue_Enum_Scroll("Attenuation", self, 0, [	new scrollItem("Quadratic",			s_node_curve_type, 0),
																				new scrollItem("Invert quadratic",	s_node_curve_type, 1),
																				new scrollItem("Linear",			s_node_curve_type, 2), ]))
			 .setTooltip("Control how light fade out over distance.");
		
		newInput(_index + 11, nodeValue_Int("Radial banding", self, 0))
			.setDisplay(VALUE_DISPLAY.slider, { range: [0, 16, 0.1] });
		
		newInput(_index + 12, nodeValue_Rotation("Radial start", self, 0));
		
		newInput(_index + 13, nodeValue_Float("Radial band ratio", self, 0.5))
			.setDisplay(VALUE_DISPLAY.slider);
		
		newInput(_index + 14, nodeValue_Bool("Active", self, true));
			
		newInput(_index + 15, nodeValue_Float("Radius x", self, 16));
		
		newInput(_index + 16, nodeValue_Float("Radius y", self, 16));
		
		newInput(_index + 17, nodeValue_Rotation("Rotation", self, 0));
		
		newInput(_index + 18, nodeValue_Float("Exponent", self, 2));
			
		newInput(_index + 19, nodeValue_Bool("Anti aliasing", self, false));
			
		newInput(_index + 20, nodeValue_Bool("Two sides", self, false));
		
		newInput(_index + 21, nodeValue_Float("Thickness", self, 2));
		
		refreshDynamicDisplay();
		return inputs[_index];
	} 
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Light only", self, VALUE_TYPE.surface, noone));
	
	lights_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		if(array_length(current_data) != array_length(inputs)) return 0;
		
		var bs = ui(24);
		var bx = _x + ui(20);
		var by = _y;
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "", THEME.add_16, 0, COLORS._main_value_positive) == 2) {
			createNewInput();
			triggerRender();
		}
			
		var amo = getInputAmount();
		var lh  = ui(28);
		var _h  = ui(12) + lh * amo;
		var yy  = _y + bs + ui(4);
		
		var del_light = -1;
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, yy, _w, _h, COLORS.node_composite_bg_blend, 1);
		
		for(var i = 0; i < amo; i++) {
			var _x0 = _x + ui(24);
			var _x1 = _x + _w - ui(16);
			var _yy = ui(6) + yy + i * lh + lh / 2;
			
			var _ind = input_fix_len + i * data_length;
			var _typ = current_data[_ind + 0];
			var _col = current_data[_ind + 4];
			
			var tc   = i == dynamic_input_inspecting? COLORS._main_text_accent : COLORS._main_icon;
			var hov  = _hover && point_in_rectangle(_m[0], _m[1], _x0, _yy - lh / 2, _x1, _yy + lh / 2 - 1);
			
			if(hov && _m[0] < _x1 - ui(32)) {
				tc = COLORS._main_text;
				
				if(mouse_press(mb_left, _focus)) {
					dynamic_input_inspecting = i;
					refreshDynamicDisplay();
				}
			}
			
			draw_sprite_ext(s_node_2d_light_shape, _typ, _x0 + ui(8), _yy, 1, 1, 0, _col, .5 + .5 * (i == dynamic_input_inspecting));
			
			draw_set_text(f_p2, fa_left, fa_center, tc);
			draw_text_add(_x0 + ui(28), _yy, typeListStr[_typ]);
			
			if(amo > 1) {
				var bs = ui(24);
				var bx = _x1 - bs;
				var by = _yy - bs / 2;
				if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "", THEME.minus_16, 0, hov? COLORS._main_value_negative : COLORS._main_icon) == 2) 
					del_light = i;	
			}
		}
		
		if(del_light > -1) 
			deleteDynamicInput(del_light);
		
		return ui(32) + _h;
	});
	
	input_display_dynamic = [ // 14, 
		["Shape",	false], 0, 1, 5, 6, 7, 8, 15, 16, 17, 20, 21,
		["Light",	false], 2, 3, 4, 11, 12, 13,
		["Render",	false], 10, 9, 18, 19, 
	];
	
	input_display_list = [ 0, lights_renderer ];
	
	setDynamicInput(22, false);
	if(!LOADING && !APPENDING) createNewInput();
	
	attribute_surface_depth();
	temp_surface = [ 0, 0, 0 ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		if(getInputAmount() == 0) return;
		
		dynamic_input_inspecting = clamp(dynamic_input_inspecting, 0, getInputAmount() - 1);
		var _ind = input_fix_len + dynamic_input_inspecting * data_length;
		
		var _shape = current_data[_ind + 0];
		var _hov   = false;
		
		draw_set_circle_precision(64);
		
		switch(_shape) {
			case LIGHT_SHAPE_2D.point :
				var pos = current_data[_ind + 1];
				var rad = current_data[_ind + 2];
				
				var px = _x + pos[0] * _s;
				var py = _y + pos[1] * _s;
				
				draw_set_color(COLORS._main_accent);
				draw_set_alpha(0.5);
				draw_circle_dash(px, py, rad * _s, 1, 8);
				draw_set_alpha(1);
				
				var hv = inputs[_ind + 1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= bool(hv); hover &= !hv;
				var hv = inputs[_ind + 2].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny); _hov |= bool(hv); hover &= !hv;
				break;
			
			case LIGHT_SHAPE_2D.ellipse :
				var pos = current_data[_ind +  1];
				var rdx = current_data[_ind + 15];
				var rdy = current_data[_ind + 16];
				var ang = current_data[_ind + 17];
				
				var px = _x + pos[0] * _s;
				var py = _y + pos[1] * _s;
				
				draw_set_color(COLORS._main_accent);
				draw_set_alpha(0.5);
				draw_ellipse_dash(px, py, rdx * _s, rdy * _s, 1, 8, ang);
				draw_set_alpha(1);
				
				var hv = inputs[_ind +  1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);           _hov |= bool(hv); hover &= !hv;
				var hv = inputs[_ind + 15].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny, ang);      _hov |= bool(hv); hover &= !hv;
				var hv = inputs[_ind + 16].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny, ang + 90); _hov |= bool(hv); hover &= !hv;
				var hv = inputs[_ind + 17].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny);           _hov |= bool(hv); hover &= !hv;
				break;
			
			case LIGHT_SHAPE_2D.line      :
			case LIGHT_SHAPE_2D.line_asym :
			case LIGHT_SHAPE_2D.spot      :
			case LIGHT_SHAPE_2D.flame     :
				var hv = inputs[_ind + 5].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= bool(hv); hover &= !hv;
				var hv = inputs[_ind + 6].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= bool(hv); hover &= !hv;
				break;
				
			case LIGHT_SHAPE_2D.saber     :
				var hv = inputs[_ind + 5].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= bool(hv); hover &= !hv;
				var hv = inputs[_ind + 6].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= bool(hv); hover &= !hv;
				
				var pos = current_data[_ind +  5];
				var rad = current_data[_ind +  2];
				var thk = current_data[_ind + 21];
				
				var px = _x + pos[0] * _s;
				var py = _y + pos[1] * _s;
				
				draw_set_color(COLORS._main_accent);
				draw_set_alpha(0.5);
				draw_circle(px, py, thk * _s, 1);
				draw_circle_dash(px, py, rad * _s, 1, 8);
				draw_set_alpha(1);
				
				inputs[_ind + 21].overlay_text_valign = fa_bottom;
				var hv = inputs[_ind +  2].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny); _hov |= bool(hv); hover &= !hv;
				var hv = inputs[_ind + 21].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny); _hov |= bool(hv); hover &= !hv;
				break;
		}
		
		return _hov;
	}
	
	static applyLight = function(_data, _ind, _lightSurf) {
		var _surf  = _data[0];
		var _dim   = surface_get_dimension(_surf);
		
		var _shape = _data[_ind +  0];
		var _pos   = _data[_ind +  1];
		var _range = _data[_ind +  2];
		var _inten = _data[_ind +  3];
		var _color = _data[_ind +  4];
		
		var _start = _data[_ind +  5];
		var _finis = _data[_ind +  6];
		var _sweep = _data[_ind +  7];
		var _swep2 = _data[_ind +  8];
		
		var _band  = _data[_ind +  9];
		var _attn  = _data[_ind + 10];
		var _rbnd  = _data[_ind + 11];
		var _rbns  = _data[_ind + 12];
		var _rbnr  = _data[_ind + 13];
		
		var _rngx  = _data[_ind + 15];
		var _rngy  = _data[_ind + 16];
		var _anng  = _data[_ind + 17];
		
		var _expo  = _data[_ind + 18];
		var _aa    = _data[_ind + 19];
		var _both  = _data[_ind + 20];
		var _thick = _data[_ind + 21];
		
		surface_set_shader(temp_surface[0], noone);
			draw_clear(c_black);
			BLEND_ADD
			
			draw_set_circle_precision(64);
			
			switch(_shape) {
				case LIGHT_SHAPE_2D.point :
					if(_rbnd < 2)
						draw_circle_color(_pos[0], _pos[1], _range, c_white, c_black,  0);
					else {
						_rbnd *= 2;
						var bnd_amo = ceil(64 / _rbnd); //band radial per step
						var step = bnd_amo * _rbnd;
						var astp = 360 / step;
						var ox, oy, nx, ny;
						
						draw_primitive_begin(pr_trianglelist);
						
						for( var i = 0; i <= step; i++ ) {
							var dir = _rbns + i * astp;
							nx = _pos[0] + lengthdir_x(_range, dir);
							ny = _pos[1] + lengthdir_y(_range, dir);
							
							if(safe_mod(i, bnd_amo) / bnd_amo < _rbnr && i) {
								draw_vertex_color(_pos[0], _pos[1], c_white, 1);
								draw_vertex_color(ox, oy, c_black, 1);
								draw_vertex_color(nx, ny, c_black, 1);
							}
							
							ox = nx;
							oy = ny;
						}
						
						draw_primitive_end();
					}
					break;
				
				case LIGHT_SHAPE_2D.ellipse :
					draw_ellipse_angle_color(_pos[0], _pos[1], _rngx, _rngy, _anng, c_white, c_black);
					break;
					
				case LIGHT_SHAPE_2D.line :
				case LIGHT_SHAPE_2D.line_asym :
					var dir = point_direction(_start[0], _start[1], _finis[0], _finis[1]) + 90;
					
					var _r  = _range / dcos(_sweep);
					var sq0 = dir + _sweep;
					var sq1 = dir - ((_shape == LIGHT_SHAPE_2D.line_asym)? _swep2 : _sweep);
					
					draw_primitive_begin(pr_trianglestrip);
						draw_vertex_color(_start[0],                        _start[1],                        c_white, 1);
						draw_vertex_color(_finis[0],                        _finis[1],                        c_white, 1);
						draw_vertex_color(_start[0] + lengthdir_x(_r, sq0), _start[1] + lengthdir_y(_r, sq0), c_black, 1);
						draw_vertex_color(_finis[0] + lengthdir_x(_r, sq1), _finis[1] + lengthdir_y(_r, sq1), c_black, 1);
					draw_primitive_end();
					
					if(_both) {
						var sq0 = 180 + dir - _sweep;
						var sq1 = 180 + dir + ((_shape == LIGHT_SHAPE_2D.line_asym)? _swep2 : _sweep);
						
						draw_primitive_begin(pr_trianglestrip);
							draw_vertex_color(_start[0],                        _start[1],                        c_white, 1);
							draw_vertex_color(_finis[0],                        _finis[1],                        c_white, 1);
							draw_vertex_color(_start[0] + lengthdir_x(_r, sq0), _start[1] + lengthdir_y(_r, sq0), c_black, 1);
							draw_vertex_color(_finis[0] + lengthdir_x(_r, sq1), _finis[1] + lengthdir_y(_r, sq1), c_black, 1);
						draw_primitive_end();
						
					}
					break;	
				
				case LIGHT_SHAPE_2D.saber :
					draw_set_color(c_white);
					draw_line_round(_start[0], _start[1], _finis[0], _finis[1], _thick * 2, true, true, 64);
					
					var _r  = _range + _thick;
					var dir = point_direction(_start[0], _start[1], _finis[0], _finis[1]) + 90;
					
					draw_primitive_begin(pr_trianglestrip);
					draw_vertex_color(_start[0],                        _start[1],                        c_white, 1);
					draw_vertex_color(_finis[0],                        _finis[1],                        c_white, 1);
					draw_vertex_color(_start[0] + lengthdir_x(_r, dir), _start[1] + lengthdir_y(_r, dir), c_black, 1);
					draw_vertex_color(_finis[0] + lengthdir_x(_r, dir), _finis[1] + lengthdir_y(_r, dir), c_black, 1);
					draw_primitive_end();
					
					draw_primitive_begin(pr_trianglelist);
					var ox, oy, nx, ny;
					for( var i = 0; i <= 90; i++ ) {
						var _d = dir + i * 2;
						nx = _start[0] + lengthdir_x(_r, _d);
						ny = _start[1] + lengthdir_y(_r, _d);
						
						if(i) {
							draw_vertex_color(_start[0], _start[1], c_white, 1);
							draw_vertex_color(ox, oy, c_black, 1);
							draw_vertex_color(nx, ny, c_black, 1);
						}
						
						ox = nx;
						oy = ny;
					}
					draw_primitive_end();
					
					dir += 180;
					draw_primitive_begin(pr_trianglestrip);
					draw_vertex_color(_start[0],                        _start[1],                        c_white, 1);
					draw_vertex_color(_finis[0],                        _finis[1],                        c_white, 1);
					draw_vertex_color(_start[0] + lengthdir_x(_r, dir), _start[1] + lengthdir_y(_r, dir), c_black, 1);
					draw_vertex_color(_finis[0] + lengthdir_x(_r, dir), _finis[1] + lengthdir_y(_r, dir), c_black, 1);
					draw_primitive_end();
					
					draw_primitive_begin(pr_trianglelist);
					var ox, oy, nx, ny;
					for( var i = 0; i <= 90; i++ ) {
						var _d = dir + i * 2;
						nx = _finis[0] + lengthdir_x(_r, _d);
						ny = _finis[1] + lengthdir_y(_r, _d);
						
						if(i) {
							draw_vertex_color(_finis[0], _finis[1], c_white, 1);
							draw_vertex_color(ox, oy, c_black, 1);
							draw_vertex_color(nx, ny, c_black, 1);
						}
						
						ox = nx;
						oy = ny;
					}
					draw_primitive_end();
					
					break;	
					
				case LIGHT_SHAPE_2D.spot :
				case LIGHT_SHAPE_2D.flame :
					var dir  = point_direction(_start[0], _start[1], _finis[0], _finis[1]);
					var astr = dir - _sweep;
					var aend = dir + _sweep;
					var stp  = 2;
					var amo  = ceil(_sweep * 2 / stp);
					var ran  = point_distance(_start[0], _start[1], _finis[0], _finis[1]);
					var cc;
					
					draw_primitive_begin(pr_trianglelist);
						for( var i = 0; i < amo; i++ )  {
							var a0 = clamp(astr + (i    ) * stp, astr, aend);
							var a1 = clamp(astr + (i + 1) * stp, astr, aend);
							
							if(_shape == LIGHT_SHAPE_2D.spot)
								cc = c_white;
							else {
								var aa = amo > 2? 1. - abs(i / (amo - 1) - .5) * 2 : 1;
								    cc = _make_color_rgb(aa, aa, aa);
							}
							
							draw_vertex_color(_start[0],                        _start[1],                        cc,      1);
							draw_vertex_color(_start[0] + lengthdir_x(ran, a0), _start[1] + lengthdir_y(ran, a0), c_black, 1);
							draw_vertex_color(_start[0] + lengthdir_x(ran, a1), _start[1] + lengthdir_y(ran, a1), c_black, 1);
						}
					draw_primitive_end();
					break;	
			}
			
		surface_reset_shader(); 
		
		var _ls = temp_surface[0];
		
		surface_set_shader(temp_surface[1], sh_2d_light);
			draw_clear(c_black);
			
			shader_set_color("color", _color);
			shader_set_f("intensity", _inten * _color_get_alpha(_color));
			shader_set_f("band",      _band);
			shader_set_i("atten",     _attn);
			shader_set_f("exponent",  _expo);
			
			BLEND_OVERRIDE draw_surface_safe(_ls);
		surface_reset_shader();
		
		_ls = temp_surface[1];
		
		if(_aa) {
			surface_set_shader(temp_surface[2], sh_FXAA);
			gpu_set_texfilter(true);
			shader_set_2("dimension",  _dim);
			shader_set_f("cornerDis",  0.5);
			shader_set_f("mixAmo",     1);
			
			BLEND_OVERRIDE draw_surface_safe(_ls);
			gpu_set_texfilter(false);
			surface_reset_shader();
			
			_ls = temp_surface[2];
		}
		
		surface_set_target(_lightSurf);
			BLEND_ADD
			draw_surface_safe(_ls);
			BLEND_NORMAL
		surface_reset_target(); 
	}
	
	static processData = function(_outData, _data, _output_index, _array_index) {
		var _surf  = _data[0];
		
		if(getInputAmount() == 0) return;
		
		#region visibility
			dynamic_input_inspecting = clamp(dynamic_input_inspecting, 0, getInputAmount() - 1);
			var _ind = input_fix_len + dynamic_input_inspecting * data_length;
			
			var _shape = _data[_ind +  0];
			var _attn  = _data[_ind + 10];
			
			inputs[_ind +  1].setVisible(false);
			inputs[_ind +  2].setVisible(false);
			inputs[_ind +  5].setVisible(false);
			inputs[_ind +  6].setVisible(false);
			inputs[_ind +  7].setVisible(false);
			inputs[_ind +  8].setVisible(false);
			inputs[_ind + 11].setVisible(false);
			inputs[_ind + 12].setVisible(false);
			inputs[_ind + 13].setVisible(false);
			inputs[_ind + 15].setVisible(false);
			inputs[_ind + 16].setVisible(false);
			inputs[_ind + 17].setVisible(false);
			inputs[_ind + 20].setVisible(false);
			inputs[_ind + 21].setVisible(false);
			
			switch(_shape) {
				case LIGHT_SHAPE_2D.point :
					inputs[_ind +  1].setVisible(true);
					inputs[_ind +  2].setVisible(true);
					inputs[_ind + 11].setVisible(true);
					inputs[_ind + 12].setVisible(true);
					inputs[_ind + 13].setVisible(true);
					break;
					
				case LIGHT_SHAPE_2D.ellipse :
					inputs[_ind +  1].setVisible(true);
					inputs[_ind + 15].setVisible(true);
					inputs[_ind + 16].setVisible(true);
					inputs[_ind + 17].setVisible(true);
					break;
					
				case LIGHT_SHAPE_2D.line :
				case LIGHT_SHAPE_2D.line_asym :
					inputs[_ind +  2].setVisible(true);
					inputs[_ind +  5].setVisible(true);
					inputs[_ind +  6].setVisible(true);
					inputs[_ind +  7].setVisible(true);
					inputs[_ind +  8].setVisible(_shape == LIGHT_SHAPE_2D.line_asym);
					inputs[_ind + 20].setVisible(true);
					break;
				
				case LIGHT_SHAPE_2D.saber :
					inputs[_ind +  2].setVisible(true);
					inputs[_ind +  5].setVisible(true);
					inputs[_ind +  6].setVisible(true);
					inputs[_ind + 21].setVisible(true);
					break;
					
				case LIGHT_SHAPE_2D.spot :
				case LIGHT_SHAPE_2D.flame :
					inputs[_ind + 5].setVisible(true);
					inputs[_ind + 6].setVisible(true);
					inputs[_ind + 7].setVisible(true);
					break;
			}
			
			inputs[_ind + 18].setVisible(_attn == 0 || _attn == 1);
		#endregion
		
		if(!is_surface(_surf)) return _outData;
		
		var _dim       = surface_get_dimension(_surf);
		var _outSurf   = surface_verify(_outData[0], _dim[0], _dim[1]);
		var _lightSurf = surface_verify(_outData[1], _dim[0], _dim[1]);
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ )
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
		
		surface_set_target(_lightSurf);
			draw_clear(c_black);
		surface_reset_target();
		
		for( var i = 0; i < getInputAmount(); i++ ) {
			var _ind = input_fix_len + i * data_length;
			applyLight(_data, _ind, _lightSurf);
		}
		
		surface_set_shader(_outSurf, sh_2d_light_apply, true, BLEND.over);
			shader_set_surface("base",  _surf);
			shader_set_surface("light", _lightSurf);
			
			draw_empty();
		surface_reset_shader(); 
		
		return [ _outSurf, _lightSurf ];
	}
	
}