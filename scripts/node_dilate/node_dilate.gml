function Node_Dilate(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Dilate";
	
	shader = sh_dilate;
	uniform_dim = shader_get_uniform(shader, "dimension");
	uniform_cen = shader_get_uniform(shader, "center");
	uniform_str = shader_get_uniform(shader, "strength");
	uniform_rad = shader_get_uniform(shader, "radius");
	uniform_sam = shader_get_uniform(shader, "sampleMode");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Center", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 2] = nodeValue("Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [-3, 3, 0.01]);
	
	inputs[| 3] = nodeValue("Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 16);
	
	inputs[| 4] = nodeValue("Oversample mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Clamp", "Repeat" ]);
	
	inputs[| 5] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 6] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 7] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 7;
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 7, 
		["Output",	 true],	0, 5, 6, 
		["Dilate",	false],	1, 2, 3,
	];
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var pos = inputs[| 1].getValue();
		var px = _x + pos[0] * _s;
		var py = _y + pos[1] * _s;
		
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[| 3].drawOverlay(active, px, py, _s, _mx, _my, _snx, _sny, 0, 1, THEME.anchor_scale_hori);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {		
		
		var center = _data[1];
		var stren = _data[2];
		var rad   = _data[3];
		var sam   = struct_try_get(attributes, "oversample");
		
		surface_set_shader(_outSurf, shader);
		shader_set_interpolation(_data[0]);
			shader_set_uniform_f_array_safe(uniform_dim, [ surface_get_width_safe(_data[0]), surface_get_height_safe(_data[0]) ]);
			shader_set_uniform_f_array_safe(uniform_cen, center);
			shader_set_uniform_f(uniform_str, stren);
			shader_set_uniform_f(uniform_rad, rad);
			shader_set_uniform_i(uniform_sam, sam);
			draw_surface_safe(_data[0], 0, 0);
		surface_reset_shader();
		
		_outSurf = mask_apply(_data[0], _outSurf, _data[5], _data[6]);
		
		return _outSurf;
	}
}