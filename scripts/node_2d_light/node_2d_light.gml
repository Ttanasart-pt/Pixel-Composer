enum LIGHT_SHAPE_2D {
	point,
	line,
	line_asym,
	spot
}

function Node_2D_light(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "2D Light";
	batch_output = false;
	
	shader = sh_2d_light;
	uniform_colr = shader_get_uniform(shader, "color");
	uniform_intn = shader_get_uniform(shader, "intensity");
	uniform_band = shader_get_uniform(shader, "band");
	uniform_attn = shader_get_uniform(shader, "atten");
	
	inputs[| 0] = nodeValue_Surface("Surface in", self);
	
	inputs[| 1] = nodeValue_Enum_Scroll("Light shape", self, 0, [	new scrollItem("Point",           s_node_2d_light_shape, 0), 
																	new scrollItem("Line",            s_node_2d_light_shape, 1), 
																	new scrollItem("Line asymmetric", s_node_2d_light_shape, 2), 
																	new scrollItem("Spot",            s_node_2d_light_shape, 3), ]);
	
	inputs[| 2] = nodeValue_Vector("Center", self, [ 16, 16 ])
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 3] = nodeValue_Float("Range", self, 16);
	
	inputs[| 4] = nodeValue_Float("Intensity", self, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 5] = nodeValue_Color("Color", self, c_white);
	
	inputs[| 6] = nodeValue_Vector("Start", self, [ 16, 16 ]);
	
	inputs[| 7] = nodeValue_Vector("Finish", self, [ 32, 16 ]);
	
	inputs[| 8] = nodeValue_Int("Sweep", self, 15)
		.setDisplay(VALUE_DISPLAY.slider, { range: [-80, 80, 0.1] });
	
	inputs[| 9] = nodeValue_Int("Sweep end", self, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [-80, 80, 0.1] });
	
	inputs[| 10] = nodeValue_Int("Banding", self, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 16, 0.1] });
	
	inputs[| 11] = nodeValue_Enum_Scroll("Attenuation", self, 0, 
											   [ new scrollItem("Quadratic",		s_node_curve, 0),
												 new scrollItem("Invert quadratic", s_node_curve, 1),
												 new scrollItem("Linear",			s_node_curve, 2), ])
		 .setTooltip("Control how light fade out over distance.");
	
	inputs[| 12] = nodeValue_Int("Radial banding", self, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 16, 0.1] });
	
	inputs[| 13] = nodeValue_Rotation("Radial start", self, 0);
	
	inputs[| 14] = nodeValue_Float("Radial band ratio", self, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 15] = nodeValue_Bool("Active", self, true);
		active_index = 15;
		
	outputs[| 0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	outputs[| 1] = nodeValue_Output("Light only", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 15, 0, 
		["Shape",	false], 1, 2, 6, 7, 8, 9, 
		["Light",	false], 3, 4, 5, 12, 13, 14,
		["Render",	false], 11, 10 
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		var _shape = current_data[1];
		var _hov   = false;
		
		switch(_shape) {
			case LIGHT_SHAPE_2D.point :
				var pos = current_data[2];
				var px = _x + pos[0] * _s;
				var py = _y + pos[1] * _s;
		
				var hv = inputs[| 2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= bool(hv);
				var hv = inputs[| 3].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny); _hov |= bool(hv);
				break;
			case LIGHT_SHAPE_2D.line :
			case LIGHT_SHAPE_2D.line_asym :
			case LIGHT_SHAPE_2D.spot :
				var hv = inputs[| 6].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= bool(hv);
				var hv = inputs[| 7].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= bool(hv);
				break;
		}
		
		return _hov;
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _shape = _data[1];
		
		switch(_shape) {
			case LIGHT_SHAPE_2D.point :
				inputs[| 2].setVisible(true);
				inputs[| 3].setVisible(true);
				inputs[| 6].setVisible(false);
				inputs[| 7].setVisible(false);
				inputs[| 8].setVisible(false);
				inputs[| 9].setVisible(false);
				
				inputs[| 12].setVisible(true);
				inputs[| 13].setVisible(true);
				inputs[| 14].setVisible(true);
				break;
			case LIGHT_SHAPE_2D.line :
			case LIGHT_SHAPE_2D.line_asym :
				inputs[| 2].setVisible(false);
				inputs[| 3].setVisible(true);
				inputs[| 6].setVisible(true);
				inputs[| 7].setVisible(true);
				inputs[| 8].setVisible(true);
				inputs[| 9].setVisible(_shape == LIGHT_SHAPE_2D.line_asym);
				
				inputs[| 12].setVisible(false);
				inputs[| 13].setVisible(false);
				inputs[| 14].setVisible(false);
				break;
			case LIGHT_SHAPE_2D.spot :
				inputs[| 2].setVisible(false);
				inputs[| 3].setVisible(false);
				inputs[| 6].setVisible(true);
				inputs[| 7].setVisible(true);
				inputs[| 8].setVisible(true);
				inputs[| 9].setVisible(false);
				
				inputs[| 12].setVisible(false);
				inputs[| 13].setVisible(false);
				inputs[| 14].setVisible(false);
				break;
		}
		
		var _range = _data[3];
		var _inten = _data[4];
		var _color = _data[5];
		
		var _pos   = _data[2];
		var _start = _data[6];
		var _finis = _data[7];
		var _sweep = _data[8];
		var _swep2 = _data[9];
		
		var _band  = _data[10];
		var _attn  = _data[11];
		
		surface_set_target(_outSurf);
			if(_output_index == 0) {
				DRAW_CLEAR
				draw_surface_safe(_data[0]);
			} else
				draw_clear_alpha(c_black, 1);
			
			BLEND_ADD;
			shader_set(shader);
			gpu_set_colorwriteenable(1, 1, 1, 0);
			
			shader_set_uniform_f(uniform_intn, _inten * _color_get_alpha(_color));
			shader_set_uniform_f(uniform_band, _band);
			shader_set_uniform_f(uniform_attn, _attn);
			shader_set_uniform_f_array_safe(uniform_colr, [ _color_get_red(_color), _color_get_green(_color), _color_get_blue(_color) ]);
			
			draw_set_circle_precision(64);
			
			switch(_shape) {
				case LIGHT_SHAPE_2D.point :
					var _rbnd = _data[12];
					var _rbns = _data[13];
					var _rbnr = _data[14];
		
					if(_rbnd < 2)
						draw_circle_color(_pos[0], _pos[1], _range, c_white, c_black,  0);
					else {
						_rbnd *= 2;
						var bnd_amo = ceil(64 / _rbnd); //band radial per step
						var step = bnd_amo * _rbnd;
						var astp = 360 / step;
						var ox, oy, nx, ny;
						var banding = false;
						
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
				case LIGHT_SHAPE_2D.line :
				case LIGHT_SHAPE_2D.line_asym :
					var dir = point_direction(_start[0], _start[1], _finis[0], _finis[1]);
					var sq0 = dir + 90 + _sweep;
					var sq1 = dir + 90 - ((_shape == LIGHT_SHAPE_2D.line_asym)? _swep2 : _sweep);
					
					var _r = _range / cos(degtorad(_sweep));
					var st_sw = [ _start[0] + lengthdir_x(_r, sq0), _start[1] + lengthdir_y(_r, sq0) ];
					var fn_sw = [ _finis[0] + lengthdir_x(_r, sq1), _finis[1] + lengthdir_y(_r, sq1) ];
					
					draw_primitive_begin(pr_trianglestrip);
						draw_vertex_color(_start[0], _start[1], c_white, 1);
						draw_vertex_color(_finis[0], _finis[1], c_white, 1);
						draw_vertex_color(st_sw[0], st_sw[1], c_black, 1);
						draw_vertex_color(fn_sw[0], fn_sw[1], c_black, 1);
					draw_primitive_end();
					break;	
				case LIGHT_SHAPE_2D.spot :
					var dir  = point_direction(_start[0], _start[1], _finis[0], _finis[1]);
					var astr = dir - _sweep;
					var aend = dir + _sweep;
					var stp  = 3;
					var amo  = ceil(_sweep * 2 / stp);
					var ran  = point_distance(_start[0], _start[1], _finis[0], _finis[1]);
					
					draw_primitive_begin(pr_trianglelist);
						for( var i = 0; i < amo; i++ )  {
							var a0 = clamp(astr + (i) * stp, astr, aend);
							var a1 = clamp(astr + (i + 1) * stp, astr, aend);
							
							draw_vertex_color(_start[0], _start[1], c_white, 1);
							draw_vertex_color(_start[0] + lengthdir_x(ran, a0), _start[1] + lengthdir_y(ran, a0), c_black, 1);
							draw_vertex_color(_start[0] + lengthdir_x(ran, a1), _start[1] + lengthdir_y(ran, a1), c_black, 1);
						}
					draw_primitive_end();
					break;	
			}
			
			gpu_set_colorwriteenable(1, 1, 1, 1);
			shader_reset();
			BLEND_NORMAL;
		surface_reset_target(); 
		
		return _outSurf;
	}
}