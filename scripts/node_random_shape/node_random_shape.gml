function Node_Random_Shape(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Random Shape";
	
	newInput(0, nodeValue_Dimension(self));
		
	newInput(1, nodeValue_Int("Seed", self, seed_random(6)))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[1].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });

	newInput(2, nodeValue_Enum_Scroll("SSAA", self, 0, [ "None", "2x", "4x", "8x" ]));
	
	newOutput(0, nodeValue_Output("Surface out",	self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		["Output",	 false], 0,
		["Shape",	 false], 1,
		["Render",	 false], 2,
	]
	
	temp_surface = [ noone ];
	
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
	
	function generateShape(_dim, _aa = 1) {
		var _sw = _dim[0] * _aa;
		var _sh = _dim[1] * _aa;
		
		var _shap = surface_create(_sw, _sh);
		surface_set_target(_shap);
			DRAW_CLEAR
			draw_set_color(c_white);
			
			var _amou = choose(1, 1, 2, 2, 3, 3, 3);
			
			repeat(_amou) {
				var _side  = min(_dim[0], _dim[1]);
				var _size  = irandom_range(_side * 0.25, _side * 0.75);
				var _shape = surface_create(_size * _aa, _size * _aa);
				
				surface_set_target(_shape);
					DRAW_CLEAR
					draw_set_color(c_white);
			
					var _x1 = _size * _aa;
					var _y1 = _size * _aa;
					var _r  = irandom(4) * 2 * _aa;
				
					switch(irandom(2)) {
						case 0 : draw_roundrect_ext(0, 0, _x1, _y1, _r, _r, false); 	break;
						case 1 : draw_ellipse(0, 0, _x1, _y1, false);					break;
						case 2 : draw_triangle(_x1 / 2, 0, 0, _y1, _x1, _y1, false);	break;
					}
				surface_reset_target();
				
				var _sx = irandom_range(_dim[0] / 2 - _size, _dim[0] / 2) * _aa;
				var _sy = irandom_range(_dim[1] / 2 - _size, _dim[1] / 2) * _aa;
				draw_surface_safe(_shape, _sx, _sy);
				surface_free(_shape);
			}
		surface_reset_target();
		
		var _surf = surface_create(_sw, _sh);
		surface_set_target(_surf);
			DRAW_CLEAR
			
			draw_surface_ext_safe(_shap,   0,   0,  1,  1, 0, c_white, 1);
			draw_surface_ext_safe(_shap, _sw,   0, -1,  1, 0, c_white, 1);
			draw_surface_ext_safe(_shap,   0, _sh,  1, -1, 0, c_white, 1);
			draw_surface_ext_safe(_shap, _sw, _sh, -1, -1, 0, c_white, 1);
		surface_reset_target();
		surface_free(_shap);
		
		return _surf;
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim  = _data[0];
		var _seed = _data[1];
		var _aa   = power(2, _data[2]);
		
		random_set_seed(_seed);
		
		var _adim = [ _dim[0] * _aa, _dim[1] * _aa ];
		var _surf = generateShape(_dim, _aa);
		var _side = irandom(2);
		var _prog = _surf;
		
		if(random(1) < 0.5) {
			_prog     = surface_create(_adim[0], _adim[1]);
			var _size = [ _dim[0] * .75, _dim[1] * 0.75 ];
			var _subs = generateShape(_size, _aa);
			var _sx   = _adim[0] / 2;
			var _sy   = _adim[1] / 2;
				
			switch(_side) {
				case 0 : _sx = irandom_range(_dim[0] / 2 - _size[0], _dim[0] / 2) * _aa; break;
				case 1 : _sy = irandom_range(_dim[1] / 2 - _size[1], _dim[1] / 2) * _aa; break;
			}
			
			surface_set_target(_prog);
				DRAW_CLEAR
				if(random(1) < 0.5) {
					shader_set(sh_rsh_rotate);
					shader_set_f("dimension", _adim[0], _adim[1]);
					draw_surface_safe(_surf);
					shader_reset();
				} else
					draw_surface_safe(_surf);
					
				BLEND_SUBTRACT
					draw_surface_safe(_subs, _sx, _sy);
				BLEND_NORMAL
			surface_reset_target();
			
			surface_free(_subs);
			surface_free(_surf);
		}
		
		// if(surfaceContentRatio(_prog) < 0.2) {
		// 	surface_free(_prog);
		// 	_prog = generateShape(_adim);
		// } 
		
		var _corn = surface_create(_dim[0], _dim[1]);
		
		temp_surface[0] = surface_verify(temp_surface[0], _adim[0], _adim[1]);
		var _cPassAA = temp_surface[0];
		
		surface_set_shader(_cPassAA, sh_rsh_corner, true, BLEND.add);
			shader_set_f("dimension", _adim[0], _adim[1]);
			shader_set_i("type", choose(0, 0, 1, 1, 1));
			
			draw_surface_safe(_prog);
			if(_side == 1) draw_surface_ext_safe(_prog, 0, _adim[1], 1, -1, 0, c_white, 1);
			if(_side == 2) draw_surface_ext_safe(_prog, _adim[0], 0, -1, 1, 0, c_white, 1);
		surface_reset_shader();
		surface_free(_prog);
		
		surface_set_shader(_corn, sh_downsample, true, BLEND.over);
			shader_set_dim("dimension", _cPassAA);
			shader_set_f("down", _aa);
			draw_surface(_cPassAA, 0, 0);
		surface_reset_shader();
		
		return _corn;
	}
}
