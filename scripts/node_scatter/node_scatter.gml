function Node_create_Scatter(_x, _y) {
	var node = new Node_Scatter(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Scatter(_x, _y) : Node(_x, _y) constructor {
	name = "Scatter";
	
	uniform_dim = shader_get_uniform(sh_blend_normal_dim, "dimension");
	uniform_pos = shader_get_uniform(sh_blend_normal_dim, "position");
	uniform_sca = shader_get_uniform(sh_blend_normal_dim, "scale");
	uniform_rot = shader_get_uniform(sh_blend_normal_dim, "rotation");
	uniform_for = shader_get_sampler_index(sh_blend_normal_dim, "fore");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2, VALUE_TAG.dimension_2d )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue(2, "Amount", self,  JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8);
	
	inputs[| 3] = nodeValue(3, "Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.vector_range);
	
	inputs[| 4] = nodeValue(4, "Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0])
		.setDisplay(VALUE_DISPLAY.rotation_range);
	
	inputs[| 5] = nodeValue(5, "Area", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ def_surf_size / 2, def_surf_size / 2, def_surf_size / 2, def_surf_size / 2, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area, function() { return inputs[| 1].getValue(); });
	
	inputs[| 6] = nodeValue(6, "Distribution", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Area", "Border" ]);
	
	inputs[| 7] = nodeValue(7, "Point at center", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 8] = nodeValue(8, "Uniform scaling", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 9] = nodeValue(9, "Scatter", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Uniform", "Random" ]);
	
	inputs[| 10] = nodeValue(10, "Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, irandom(9999999));
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	input_display_list = [ 0, 1, 10, 
		["Area",	false], 5, 6, 9, 
		["Scatter", false], 2, 3, 8, 7, 4
	];
	
	temp_surf = [ PIXEL_SURFACE, PIXEL_SURFACE ];
	
	static drawOverlay = function(_active, _x, _y, _s, _mx, _my) {
		inputs[| 5].drawOverlay(_active, _x, _y, _s, _mx, _my);
	}
	
	static update = function() {
		var _inSurf = inputs[| 0].getValue(), surf;
		if(_inSurf == 0)
			return;
		
		var _outSurf	= outputs[| 0].getValue();
		
		var _dim	= inputs[| 1].getValue();
		var _amount	= inputs[| 2].getValue();
		var _scale	= inputs[| 3].getValue();
		var _rota	= inputs[| 4].getValue();
		
		var _area	= inputs[| 5].getValue();
		
		var _dist	= inputs[| 6].getValue();
		var _scat	= inputs[| 9].getValue();
		
		var _pint	= inputs[| 7].getValue();
		var _unis	= inputs[| 8].getValue();
		
		var seed	= inputs[| 10].getValue();
		random_set_seed(seed);
		
		var _in_w, _in_h;
		
		if(is_surface(_outSurf)) 
			surface_size_to(_outSurf, surface_valid(_dim[0]), surface_valid(_dim[1]));
		else {
			_outSurf = surface_create(surface_valid(_dim[0]), surface_valid(_dim[1]));
			outputs[| 0].setValue(_outSurf);
		}
		
		var ww = surface_get_width(_outSurf);
		var hh = surface_get_height(_outSurf);
		
		for(var i = 0; i < 2; i++) {
			if(!is_surface(temp_surf[i])) 
				temp_surf[i] = surface_create(ww, hh);
			else 
				surface_size_to(temp_surf[i], ww, hh);
			
			surface_set_target(temp_surf[i]);
			draw_clear_alpha(0, 0);
			surface_reset_target();
		}
		
		BLEND_OVERRIDE
		var res_index = 0, bg = 0;
		for(var i = 0; i < _amount; i++) {
			var sp = area_get_random_point(_area, _dist, _scat, i, _amount);
			var _x = sp[0];
			var _y = sp[1];
			
			var _scx = random_range(_scale[0], _scale[1]);
			var _scy = random_range(_scale[2], _scale[3]);
			if(_unis) _scy = _scx;
				
			var _r	 = (_pint? point_direction(_area[0], _area[1], _x, _y) : 0) + random_range(_rota[0], _rota[1]);
				
			surf = _inSurf;
			if(is_array(_inSurf)) 
				surf = _inSurf[irandom(array_length(_inSurf) - 1)];
			
			var sw = surface_get_width(surf);
			var sh = surface_get_height(surf);
			
			if(_dist != AREA_DISTRIBUTION.area || _scat != AREA_SCATTER.uniform) {
				_x -= sw / 2;
				_y -= sh / 2;
			}
					
			surface_set_target(temp_surf[bg]);
				shader_set(sh_blend_normal_dim);
				shader_set_uniform_f_array(uniform_dim, [ sw / ww, sh / hh ]);
				shader_set_uniform_f_array(uniform_pos, [ _x / ww, _y / hh]); 
				shader_set_uniform_f_array(uniform_sca, [ _scx, _scy ]) 
				shader_set_uniform_f(uniform_rot, degtorad(_r)); 
				texture_set_stage(uniform_for, surface_get_texture(surf));
				
				draw_surface_safe(temp_surf[!bg], 0, 0);
				shader_reset();
			surface_reset_target();
			
			res_index = bg;
			bg = !bg;
		}
		BLEND_NORMAL
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_ADD
			
			draw_surface_safe(temp_surf[res_index], 0, 0);
			
			BLEND_NORMAL
		surface_reset_target();
	}
	
}