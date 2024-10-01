enum LIGHT_SHAPE_2D {
	point,
	line,
	line_asym,
	spot,
	ellipse,
}

function Node_2D_light(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "2D Light";
	batch_output = false;
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Enum_Scroll("Light shape", self, 0, [	new scrollItem("Point",           s_node_2d_light_shape, 0), 
																new scrollItem("Line",            s_node_2d_light_shape, 1), 
																new scrollItem("Line asymmetric", s_node_2d_light_shape, 2), 
																new scrollItem("Spot",            s_node_2d_light_shape, 3), 
																new scrollItem("Ellipse",         s_node_2d_light_shape, 4), ]));
	
	newInput(2, nodeValue_Vec2("Center", self, [ 16, 16 ]))
		.setUnitRef(function(index) { return getDimension(index); });
	
	newInput(3, nodeValue_Float("Range", self, 16));
	
	newInput(4, nodeValue_Float("Intensity", self, 1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ]});
	
	newInput(5, nodeValue_Color("Color", self, c_white));
	
	newInput(6, nodeValue_Vec2("Start", self, [ 16, 16 ]));
	
	newInput(7, nodeValue_Vec2("Finish", self, [ 32, 16 ]));
	
	newInput(8, nodeValue_Int("Sweep", self, 15))
		.setDisplay(VALUE_DISPLAY.slider, { range: [-80, 80, 0.1] });
	
	newInput(9, nodeValue_Int("Sweep end", self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [-80, 80, 0.1] });
	
	newInput(10, nodeValue_Int("Banding", self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 16, 0.1] });
	
	newInput(11, nodeValue_Enum_Scroll("Attenuation", self, 0, 
											   [ new scrollItem("Quadratic",		s_node_curve, 0),
												 new scrollItem("Invert quadratic", s_node_curve, 1),
												 new scrollItem("Linear",			s_node_curve, 2), ]))
		 .setTooltip("Control how light fade out over distance.");
	
	newInput(12, nodeValue_Int("Radial banding", self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 16, 0.1] });
	
	newInput(13, nodeValue_Rotation("Radial start", self, 0));
	
	newInput(14, nodeValue_Float("Radial band ratio", self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(15, nodeValue_Bool("Active", self, true));
		active_index = 15;
		
	newInput(16, nodeValue_Float("Radius x", self, 16));
	
	newInput(17, nodeValue_Float("Radius y", self, 16));
	
	newInput(18, nodeValue_Rotation("Rotation", self, 0));
		
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	newOutput(1, nodeValue_Output("Light only", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 15, 0, 
		["Shape",	false], 1, 2, 6, 7, 8, 9, 16, 17, 18, 
		["Light",	false], 3, 4, 5, 12, 13, 14,
		["Render",	false], 11, 10, 
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		var _shape = current_data[1];
		var _hov   = false;
		
		switch(_shape) {
			case LIGHT_SHAPE_2D.point :
				var pos = current_data[2];
				var rad = current_data[3];
				
				var px = _x + pos[0] * _s;
				var py = _y + pos[1] * _s;
				
				draw_set_color(COLORS._main_accent);
				draw_set_alpha(0.5);
				draw_circle_dash(px, py, rad * _s, 1, 8);
				draw_set_alpha(1);
				
				var hv = inputs[2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= bool(hv); hover &= !hv;
				var hv = inputs[3].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny); _hov |= bool(hv); hover &= !hv;
				break;
			
			case LIGHT_SHAPE_2D.ellipse :
				var pos = current_data[ 2];
				var rdx = current_data[16];
				var rdy = current_data[17];
				var ang = current_data[18];
				
				var px = _x + pos[0] * _s;
				var py = _y + pos[1] * _s;
				
				draw_set_color(COLORS._main_accent);
				draw_set_alpha(0.5);
				draw_ellipse_dash(px, py, rdx * _s, rdy * _s, 1, 8, ang);
				draw_set_alpha(1);
				
				var hv = inputs[ 2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);           _hov |= bool(hv); hover &= !hv;
				var hv = inputs[16].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny, ang);      _hov |= bool(hv); hover &= !hv;
				var hv = inputs[17].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny, ang + 90); _hov |= bool(hv); hover &= !hv;
				var hv = inputs[18].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny);           _hov |= bool(hv); hover &= !hv;
				break;
			
			case LIGHT_SHAPE_2D.line :
			case LIGHT_SHAPE_2D.line_asym :
			case LIGHT_SHAPE_2D.spot :
				var hv = inputs[6].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= bool(hv); hover &= !hv;
				var hv = inputs[7].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= bool(hv); hover &= !hv;
				break;
		}
		
		return _hov;
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _shape = _data[1];
		
		inputs[ 2].setVisible(false);
		inputs[ 3].setVisible(false);
		inputs[ 6].setVisible(false);
		inputs[ 7].setVisible(false);
		inputs[ 8].setVisible(false);
		inputs[ 9].setVisible(false);
		inputs[12].setVisible(false);
		inputs[13].setVisible(false);
		inputs[14].setVisible(false);
		inputs[16].setVisible(false);
		inputs[17].setVisible(false);
		inputs[18].setVisible(false);
		
		switch(_shape) {
			case LIGHT_SHAPE_2D.point :
				inputs[2].setVisible(true);
				inputs[3].setVisible(true);
				
				inputs[12].setVisible(true);
				inputs[13].setVisible(true);
				inputs[14].setVisible(true);
				break;
				
			case LIGHT_SHAPE_2D.ellipse :
				inputs[2].setVisible(true);
				
				inputs[16].setVisible(true);
				inputs[17].setVisible(true);
				inputs[18].setVisible(true);
				break;
				
			case LIGHT_SHAPE_2D.line :
			case LIGHT_SHAPE_2D.line_asym :
				inputs[3].setVisible(true);
				inputs[6].setVisible(true);
				inputs[7].setVisible(true);
				inputs[8].setVisible(true);
				inputs[9].setVisible(_shape == LIGHT_SHAPE_2D.line_asym);
				break;
				
			case LIGHT_SHAPE_2D.spot :
				inputs[6].setVisible(true);
				inputs[7].setVisible(true);
				inputs[8].setVisible(true);
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
		shader_set(sh_2d_light);
		gpu_set_colorwriteenable(1, 1, 1, 0);
		
		shader_set_color("color", _color);
		shader_set_f("intensity", _inten * _color_get_alpha(_color));
		shader_set_f("band",      _band);
		shader_set_f("atten",     _attn);
		
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
			
			case LIGHT_SHAPE_2D.ellipse :
				var _rngx = _data[16];
				var _rngy = _data[17];
				var _anng = _data[18];
				
				draw_ellipse_angle_color(_pos[0], _pos[1], _rngx, _rngy, _anng, c_white, c_black);
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