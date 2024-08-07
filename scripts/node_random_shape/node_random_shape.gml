function Node_Random_Shape(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Random Shape";
	
	inputs[| 0] = nodeValue_Dimension(self);
		
	inputs[| 1] = nodeValue_Int("Seed", self, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[| 1].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });

	outputs[| 0] = nodeValue_Output("Surface out",	self, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 
		["Output",	 false], 0,
		["Shape",	 false], 1
	]
	
	function surfaceContentRatio(_surf) {
		var s     = 0;
		var _sw   = surface_get_width_safe(_surf);
		var _sh   = surface_get_height_safe(_surf);
		var total = _sw * _sh;
		var _buff = buffer_create(_sw * _sh * 4, buffer_fixed, 4);
		buffer_get_surface(_buff, _surf, 0);
		buffer_seek(_buff, buffer_seek_start, 0);
		
		repeat(total) {
			var b = buffer_read(_buff, buffer_u32);
			if(b) s++;
		}
		
		buffer_delete(_buff);
		
		return s / total;
	}
	
	function generateShape(_dim) {
		var _shap = surface_create(_dim[0], _dim[1]);
		surface_set_target(_shap);
			DRAW_CLEAR
			draw_set_color(c_white);
			
			var _amou = choose(1, 1, 2, 2, 3, 3, 3);
			
			repeat(_amou) {
				var _side  = min(_dim[0], _dim[1]);
				var _size  = irandom_range(_side * 0.25, _side * 0.75);
				var _shape = surface_create(_size, _size);
				
				surface_set_target(_shape);
					DRAW_CLEAR
					draw_set_color(c_white);
			
					var _cx = _size / 2;
					var _cy = _size / 2;
					var _sx = _size / 2;
					var _sy = _size / 2;
				
					var _x0 = _cx - _sx;
					var _y0 = _cy - _sy;
					var _x1 = _cx + _sx;
					var _y1 = _cy + _sy;
				
					var _r = irandom(4) * 2;
				
					switch(irandom(2)) {
						case 0 : draw_roundrect_ext(_x0, _y0, _x1, _y1, _r, _r, false); break;
						case 1 : draw_ellipse(_x0, _y0, _x1, _y1, false); break;
						case 2 : draw_triangle((_x0 + _x1) / 2, _y0, _x0, _y1, _x1, _y1, false); break;
					}
				surface_reset_target();
				
				var _sx = irandom_range(_dim[0] / 2 - _size / 2, _dim[0] / 2 + _size / 2);
				var _sy = irandom_range(_dim[1] / 2 - _size / 2, _dim[1] / 2 + _size / 2);
				draw_surface_safe(_shape, _sx - _size / 2, _sy - _size / 2);
				surface_free(_shape);
			}
		surface_reset_target();
		
		var _surf = surface_create(_dim[0], _dim[1]);
		surface_set_target(_surf);
			DRAW_CLEAR
			
			draw_surface_ext_safe(_shap,       0,       0,  1,  1, 0, c_white, 1);
			draw_surface_ext_safe(_shap, _dim[0],       0, -1,  1, 0, c_white, 1);
			draw_surface_ext_safe(_shap,       0, _dim[1],  1, -1, 0, c_white, 1);
			draw_surface_ext_safe(_shap, _dim[0], _dim[1], -1, -1, 0, c_white, 1);
		surface_reset_target();
		surface_free(_shap);
		
		return _surf;
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim  = _data[0];
		var _seed = _data[1];
		
		random_set_seed(_seed);
		
		var _surf = generateShape(_dim);
		var _prog;
		var _side = irandom(2);
		
		if(random(1) < 0.5) {
			_prog     = surface_create(_dim[0], _dim[1]);
			var _size = [ _dim[0] * .75, _dim[1] * 0.75 ];
			var _subs = generateShape(_size);
			var _sx   = _dim[0] / 2;
			var _sy   = _dim[1] / 2;
				
			switch(_side) {
				case 0 : _sx = irandom_range(_dim[0] / 2 - _size[0] / 2, _dim[0] / 2 + _size[0] / 2); break;
				case 1 : _sy = irandom_range(_dim[1] / 2 - _size[1] / 2, _dim[1] / 2 + _size[1] / 2); break;
			}
			
			surface_set_target(_prog);
				DRAW_CLEAR
				if(random(1) < 0.5) {
					shader_set(sh_rsh_rotate);
					shader_set_f("dimension", _dim[0], _dim[1]);
					draw_surface_safe(_surf);
					shader_reset();
				} else
					draw_surface_safe(_surf);
					
				BLEND_SUBTRACT
					draw_surface_safe(_subs, _sx - _size[0] / 2, _sy - _size[1] / 2);
				BLEND_NORMAL
			surface_reset_target();
			surface_free(_subs);
			surface_free(_surf);
		} else 
			_prog = _surf;
		
		var _rat = surfaceContentRatio(_prog);
		
		if(_rat < 0.2) {
			surface_free(_prog);
			_prog = generateShape(_dim);
		} 
		
		var _corn = surface_create(_dim[0], _dim[1]);
		
		surface_set_shader(_corn, sh_rsh_corner, true, BLEND.add);
			shader_set_f("dimension", _dim[0], _dim[1]);
			shader_set_i("type", choose(0, 0, 1, 1, 1));
			
			draw_surface_safe(_prog);
			if(_side == 1) draw_surface_ext_safe(_prog, 0, _dim[1], 1, -1, 0, c_white, 1);
			if(_side == 2) draw_surface_ext_safe(_prog, _dim[0], 0, -1, 1, 0, c_white, 1);
		surface_reset_shader();
		surface_free(_prog);
		
		return _corn;
	}
}
