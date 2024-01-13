function Node_MK_Flare(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Lens Flare";
	dimension_index = 3;
	
	inputs[| 0] = nodeValue("Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Origin", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ DEF_SURF_W / 2, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Lens", "Crescent" ]);
		
	inputs[| 3] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 4] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		
	inputs[| 5] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
		
	outputs[| 1] = nodeValue("Light only", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 
		["Surfaces", false], 0, 3, 
		["Flare",	 false], 2, 1, 4, 
		["Render",	 false], 5, 
	]
	
	temp_surface = [ surface_create(1, 1) ];
	seed = seed_random();
	
	flares = [];
	
	ox = 0;
	oy = 0;
	cx = 0
	cy = 0
		
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	} #endregion
	
	static flare_circle = function(_t, _r, _a, _side = 16, _angle = 0, _s0 = 0, _s1 = 0) { #region
		var _x = lerp(ox, cx, _t);
		var _y = lerp(oy, cy, _t);
		
		temp_surface[0] = surface_verify(temp_surface[0], _r * 2, _r * 2);
		
		surface_set_shader(temp_surface[0], sh_draw_grey_alpha);
			shader_set_f("smooth", _s0, _s1);
			draw_primitive_begin(pr_trianglelist);
			
			for( var i = 0; i < _side; i++ ) {
				var a0 = ((i + 0.0) / _side) * 360 + _angle;
				var a1 = ((i + 1.0) / _side) * 360 + _angle;
				
				draw_vertex_color(_r, _r, c_white, 1)
				draw_vertex_color(_r + lengthdir_x(_r, a0), _r + lengthdir_y(_r, a0), c_black, 1)
				draw_vertex_color(_r + lengthdir_x(_r, a1), _r + lengthdir_y(_r, a1), c_black, 1)
			}
			
			draw_primitive_end();
		surface_reset_shader();
		
		BLEND_ADD draw_surface_ext(temp_surface[0], _x - _r, _y - _r, 1, 1, 0, c_white, _a);
	} #endregion
	
	static flare_crescent = function(_t, _ir, _or, _a, _dist = 0, _angle = 0, _s0 = 0, _s1 = 0) { #region
		var _x = lerp(ox, cx, _t);
		var _y = lerp(oy, cy, _t);
		
		var _r = _or;
		
		temp_surface[0] = surface_verify(temp_surface[0], _r * 2, _r * 2);
		
		surface_set_shader(temp_surface[0], sh_draw_grey_alpha);
			shader_set_f("smooth", _s0, _s1);
			
			draw_circle_color(_r, _r, _or, c_white, c_black, false);
			
			var _rx = _r + lengthdir_x(_dist, _angle);
			var _ry = _r + lengthdir_y(_dist, _angle);
			
			BLEND_SUBTRACT
			draw_circle_color(_rx, _ry, _ir, c_white, c_black, false);
			BLEND_NORMAL
		surface_reset_shader();
		
		BLEND_ADD draw_surface_ext(temp_surface[0], _x - _r, _y - _r, 1, 1, 0, c_white, _a);
	} #endregion
	
	static flare_blur = function(_t, _r, _a, _s0 = 0, _s1 = 1) { #region
		var _x = lerp(ox, cx, _t);
		var _y = lerp(oy, cy, _t);
		
		temp_surface[0] = surface_verify(temp_surface[0], _r * 2, _r * 2);
		
		surface_set_shader(temp_surface[0], sh_draw_grey_alpha);
			shader_set_f("smooth", _s0, _s1);
			
			draw_circle_color(_r - 1, _r - 1, _r, c_white, c_black, false);
		surface_reset_shader();
		
		BLEND_ADD draw_surface_ext(temp_surface[0], _x - _r, _y - _r, 1, 1, 0, c_white, _a);
	} #endregion
	
	static flare_ring = function(_t, _r, _a, _th, _s0 = 0, _s1 = 0) { #region
		var _x = lerp(ox, cx, _t);
		var _y = lerp(oy, cy, _t);
		
		temp_surface[0] = surface_verify(temp_surface[0], _r * 2, _r * 2);
		
		var _side = 32;
		var _r0 = _r - _th;
		var _r1 = _r - _th / 2;
		var _r2 = _r;
		
		surface_set_shader(temp_surface[0], sh_draw_grey_alpha);
			shader_set_f("smooth", _s0, _s1);
			draw_primitive_begin(pr_trianglelist);
			
			for( var i = 0; i < _side; i++ ) {
				var a0 = ((i + 0.0) / _side) * 360;
				var a1 = ((i + 1.0) / _side) * 360;
				
				draw_vertex_color(_r + lengthdir_x(_r1, a0), _r + lengthdir_y(_r1, a0), c_white, 1);
				draw_vertex_color(_r + lengthdir_x(_r0, a0), _r + lengthdir_y(_r0, a0), c_black, 1);
				draw_vertex_color(_r + lengthdir_x(_r1, a1), _r + lengthdir_y(_r1, a1), c_white, 1);
				
				draw_vertex_color(_r + lengthdir_x(_r0, a0), _r + lengthdir_y(_r0, a0), c_black, 1);
				draw_vertex_color(_r + lengthdir_x(_r1, a1), _r + lengthdir_y(_r1, a1), c_white, 1);
				draw_vertex_color(_r + lengthdir_x(_r0, a1), _r + lengthdir_y(_r0, a1), c_black, 1);
				
				draw_vertex_color(_r + lengthdir_x(_r1, a0), _r + lengthdir_y(_r1, a0), c_white, 1);
				draw_vertex_color(_r + lengthdir_x(_r2, a0), _r + lengthdir_y(_r2, a0), c_black, 1);
				draw_vertex_color(_r + lengthdir_x(_r1, a1), _r + lengthdir_y(_r1, a1), c_white, 1);
				
				draw_vertex_color(_r + lengthdir_x(_r2, a0), _r + lengthdir_y(_r2, a0), c_black, 1);
				draw_vertex_color(_r + lengthdir_x(_r1, a1), _r + lengthdir_y(_r1, a1), c_white, 1);
				draw_vertex_color(_r + lengthdir_x(_r2, a1), _r + lengthdir_y(_r2, a1), c_black, 1);
			}
			
			draw_primitive_end();
		surface_reset_shader();
		
		BLEND_ADD draw_surface_ext(temp_surface[0], _x - _r, _y - _r, 1, 1, 0, c_white, _a);
	} #endregion
	
	static flare_star = function(_t, _ir, _or, _a, _amo, _rand = 1., _ang = 0) { #region
		var _x = lerp(ox, cx, _t);
		var _y = lerp(oy, cy, _t);
		
		temp_surface[0] = surface_verify(temp_surface[0], _or * 2, _or * 2);
		
		var cc = _or;
		
		surface_set_shader(temp_surface[0], sh_draw_grey_alpha);
			draw_primitive_begin(pr_trianglelist);
			random_set_seed(seed);
			
			for( var i = 0; i < _amo; i++ ) {
				var a0 = ((i + 0.0) / _amo) * 360 + _ang;
				var a1 = ((i + random_range(0., 1.)) / _amo) * 360 + _ang;
				var a2 = ((i + 1.0) / _amo) * 360 + _ang;
				
				draw_vertex_color(cc, cc, c_white, 1);
				draw_vertex_color(cc + lengthdir_x(_ir, a0), cc + lengthdir_y(_ir, a0), c_grey,  1);
				draw_vertex_color(cc + lengthdir_x(_or, a1), cc + lengthdir_y(_or, a1), c_black, 1);
				
				draw_vertex_color(cc, cc, c_white, 1);
				draw_vertex_color(cc + lengthdir_x(_or, a1), cc + lengthdir_y(_or, a1), c_black, 1);
				draw_vertex_color(cc + lengthdir_x(_ir, a2), cc + lengthdir_y(_ir, a2), c_grey,  1);
			}
			
			draw_primitive_end();
		surface_reset_shader();
		
		BLEND_ADD draw_surface_ext(temp_surface[0], _x - _or, _y - _or, 1, 1, 0, c_white, _a);
	} #endregion
	
	static flare_line = function(_r, _a, _th, _dir) { #region
		var _x = cx;
		var _y = cy;
		
		temp_surface[0] = surface_verify(temp_surface[0], _r * 2, _r * 2);
		
		surface_set_shader(temp_surface[0], sh_draw_grey_alpha);
			shader_set_f("smooth", 0, 1);
			
			draw_primitive_begin(pr_trianglelist);
			
			var x0 = _r + lengthdir_x(_r,  _dir);
			var y0 = _r + lengthdir_y(_r,  _dir);
			var x1 = _r + lengthdir_x(_th, _dir +  90);
			var y1 = _r + lengthdir_y(_th, _dir +  90);
			var x2 = _r + lengthdir_x(_th, _dir + 270);
			var y2 = _r + lengthdir_y(_th, _dir + 270);
			var x3 = _r + lengthdir_x(_r,  _dir + 180);
			var y3 = _r + lengthdir_y(_r,  _dir + 180);
			
			draw_vertex_color(_r, _r, c_white, 1);
			draw_vertex_color(x0, y0, c_black, 1);
			draw_vertex_color(x1, y1, c_black, 1);
			
			draw_vertex_color(_r, _r, c_white, 1);
			draw_vertex_color(x0, y0, c_black, 1);
			draw_vertex_color(x2, y2, c_black, 1);
			
			draw_vertex_color(_r, _r, c_white, 1);
			draw_vertex_color(x3, y3, c_black, 1);
			draw_vertex_color(x1, y1, c_black, 1);
			
			draw_vertex_color(_r, _r, c_white, 1);
			draw_vertex_color(x3, y3, c_black, 1);
			draw_vertex_color(x2, y2, c_black, 1);
			
			draw_primitive_end();
		surface_reset_shader();
		
		BLEND_ADD draw_surface_ext(temp_surface[0], _x - _r, _y - _r, 1, 1, 0, c_white, _a);
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		if(_output_index == 1) return flares[_array_index];
		
		var _surf   = _data[0];
		var _origin = _data[1];
		var _type   = _data[2];
		var _dim    = _data[3];
		var _s      = _data[4];
		var _a      = _data[5];
		
		var _bg = is_surface(_surf);
		
		var _sw = _bg? surface_get_width_safe(_surf)  : _dim[0];
		var _sh = _bg? surface_get_height_safe(_surf) : _dim[1];
		
		var _focus  = [ _sw / 2, _sh / 2 ];
		
		_outSurf = surface_verify(_outSurf, _sw, _sh);
		flares[_array_index] = surface_verify(array_safe_get(flares, _array_index), _sw, _sh);
		
		ox = _origin[0];
		oy = _origin[1];
		cx = _focus[0];
		cy = _focus[1];
		
		var _dir = point_direction(cx, cy, ox, oy);
		var _dis = point_distance(cx, cy, ox, oy);
		
		var _x, _y;
		
		surface_set_target(flares[_array_index]);
			draw_clear_alpha(c_white, 0);
			
			switch(_type) {
				case 0 :
					flare_blur(  0, 10 * _s, 0.75 * _a);
					flare_blur(  0, 16 * _s, 0.5  * _a);
					flare_star(  0,  3 * _s, 16 * _s, 0.4 * _a, min(24, 12 * _s), 0.85, _dir);
					flare_ring(  0,  6 * _s, 0.25 * _a, 1 + 0.25 * _s, 0, 0.5);
					
					flare_blur(  0.7, 2.0 * _s, 0.5 * _a, 0, 0.25);
					flare_circle(0.9, 2.0 * _s, 0.5 * _a, 6, _dir, 0, 0.1);
					flare_circle(1.2, 0.5 * _s, 0.3 * _a);
					
					flare_blur(  1.5, 5 * _s, 0.4 * _a, 0, 0.7);
					flare_circle(1.6, 3 * _s, 0.4 * _a, 6, _dir);
					flare_ring(  1.9, 4 * _s, 0.3 * _a, 1 + 0.25 * _s, 0, 0.5);
					flare_blur(  1.9, 3 * _s, 0.3 * _a, 0, 0.5);
					break;
				case 1 :
					flare_crescent(0.5,  7.2 * _s, 7.5 * _s, 0.8 * _a, -0.2 * _s, _dir, 0.15, 0.2);
					flare_crescent(0.7,  4.7 * _s, 5   * _s, 0.6 * _a, -0.2 * _s, _dir, 0.15, 0.2);
					
					flare_circle(  1.35, 2.0 * _s, 0.6 * _a, 32, 0, 0.4, 0.6);
					flare_circle(  1.5 , 3.0 * _s, 0.4 * _a, 32, 0, 0.1, 0.2);
					flare_ring(    1.75, 4.0 * _s, 0.6 * _a, 0.2 * _s, 0.1, 0.2);
					
					flare_line(_dis * 1.0, 0.6 * _a, 1 + 0.25 * _s, _dir);
					break;
			}
			
			BLEND_NORMAL
		surface_reset_target();
		
		surface_set_target(_outSurf);
			draw_clear_alpha(c_white, 0);
			
			if(_bg) {
				BLEND_OVERRIDE
					draw_surface(_surf, 0, 0);
			}
			
			BLEND_ADD
				draw_surface(flares[_array_index], 0, 0);
				
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}