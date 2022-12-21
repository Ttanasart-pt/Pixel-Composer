enum LIGHT_SHAPE_2D {
	point,
	line,
	line_asym,
	spot
}

function Node_2D_light(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "2D light";
	
	shader = sh_2d_light;
	uniform_colr = shader_get_uniform(shader, "color");
	uniform_intn = shader_get_uniform(shader, "intensity");
	uniform_band = shader_get_uniform(shader, "band");
	uniform_attn = shader_get_uniform(shader, "atten");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Light shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Point", "Line", "Line asymmetric", "Spot" ]);
	
	inputs[| 2] = nodeValue(2, "Center", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 16, 16])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 16);
	inputs[| 4] = nodeValue(4, "Intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 5] = nodeValue(5, "Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 6] = nodeValue(6, "Start", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 16, 16])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 7] = nodeValue(7, "Finish", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 32, 16])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 8] = nodeValue(8, "Sweep", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 15)
		.setDisplay(VALUE_DISPLAY.slider, [-80, 80, 1]);
	
	inputs[| 9] = nodeValue(9, "Sweep end", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.slider, [-80, 80, 1]);
	
	inputs[| 10] = nodeValue(10, "Banding", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.slider, [0, 16, 1]);
	
	inputs[| 11] = nodeValue(11, "Attenuation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Quadratic", "Invert quadratic", "Linear"]);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	outputs[| 1] = nodeValue(1, "Light only", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	input_display_list = [ 0, 
		["Shape",	false], 1, 2, 6, 7, 8, 9, 
		["Light",	false], 3, 4, 5,
		["Render",	false], 11, 10 
	];
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _shape = inputs[| 1].getValue();
		
		switch(_shape) {
			case LIGHT_SHAPE_2D.point :
				var pos = inputs[| 2].getValue();
				var px = _x + pos[0] * _s;
				var py = _y + pos[1] * _s;
		
				inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
				inputs[| 3].drawOverlay(active, px, py, _s, _mx, _my, _snx, _sny);
				break;
			case LIGHT_SHAPE_2D.line :
			case LIGHT_SHAPE_2D.line_asym :
			case LIGHT_SHAPE_2D.spot :
				inputs[| 6].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
				inputs[| 7].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
				break;
		}
	}
	
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _shape = _data[1];
		
		switch(_shape) {
			case LIGHT_SHAPE_2D.point :
				inputs[| 2].setVisible(true);
				inputs[| 3].setVisible(true);
				inputs[| 6].setVisible(false);
				inputs[| 7].setVisible(false);
				inputs[| 8].setVisible(false);
				inputs[| 9].setVisible(false);
				break;
			case LIGHT_SHAPE_2D.line :
			case LIGHT_SHAPE_2D.line_asym :
				inputs[| 2].setVisible(false);
				inputs[| 3].setVisible(true);
				inputs[| 6].setVisible(true);
				inputs[| 7].setVisible(true);
				inputs[| 8].setVisible(true);
				inputs[| 9].setVisible(_shape == LIGHT_SHAPE_2D.line_asym);
				break;
			case LIGHT_SHAPE_2D.spot :
				inputs[| 2].setVisible(false);
				inputs[| 3].setVisible(false);
				inputs[| 6].setVisible(true);
				inputs[| 7].setVisible(true);
				inputs[| 8].setVisible(true);
				inputs[| 9].setVisible(false);
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
				draw_clear_alpha(0, 0);
				draw_surface_safe(_data[0], 0, 0);
			} else {
				draw_clear_alpha(c_black, 1);
			}
			
			BLEND_ADD
			shader_set(shader);
			gpu_set_colorwriteenable(1, 1, 1, 0);
			
			shader_set_uniform_f(uniform_intn, _inten);
			shader_set_uniform_f(uniform_band, _band);
			shader_set_uniform_f(uniform_attn, _attn);
			shader_set_uniform_f_array(uniform_colr, [ color_get_red(_color) / 255, color_get_green(_color) / 255, color_get_blue(_color) / 255 ]);
			
			switch(_shape) {
				case LIGHT_SHAPE_2D.point :
					draw_circle_color(_pos[0], _pos[1], _range, c_white, c_black,  0);
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
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}