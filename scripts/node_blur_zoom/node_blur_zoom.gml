function Node_Blur_Zoom(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Zoom Blur";
	
	shader = sh_blur_zoom;
	uniform_str = shader_get_uniform(shader, "strength");
	uniform_cen = shader_get_uniform(shader, "center");
	uniform_blr = shader_get_uniform(shader, "blurMode");
	uniform_sam = shader_get_uniform(shader, "sampleMode");
	
	uniform_umk = shader_get_uniform(shader, "useMask");
	uniform_msk = shader_get_sampler_index(shader, "mask");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2);
	
	inputs[| 2] = nodeValue("Center",   self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
		
	inputs[| 3] = nodeValue("Oversample mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Clamp", "Repeat" ]);
		
	inputs[| 4] = nodeValue("Zoom mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Start", "Middle", "End" ]);
		
	inputs[| 5] = nodeValue("Blur mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 6] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 7] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 8] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 8;
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 8,
		["Output", 	 true],	0, 6, 7, 
		["Blur",	false],	1, 2, 4, 5
	];
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var pos = inputs[| 2].getValue();
		var px = _x + pos[0] * _s;
		var py = _y + pos[1] * _s;
		
		inputs[| 1].drawOverlay(active, px, py, _s, _mx, _my, _snx, _sny, 0, 64, THEME.anchor_scale_hori);
		inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _str = _data[1];
		var _cen = _data[2];
		var _sam = struct_try_get(attributes, "oversample");
		var _blr = _data[4];
		var _msk = _data[5];
		var _mask = _data[6];
		var _mix  = _data[7];
		_cen[0] /= surface_get_width(_outSurf);
		_cen[1] /= surface_get_height(_outSurf);
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			BLEND_OVERRIDE;
		
			shader_set(shader);
			shader_set_uniform_f(uniform_str, _str);
			shader_set_uniform_f_array_safe(uniform_cen, _cen);
			shader_set_uniform_i(uniform_blr, _blr);
			shader_set_uniform_i(uniform_sam, _sam);
			
			shader_set_uniform_i(uniform_umk, is_surface(_msk));
			if(is_surface(_msk)) 
				texture_set_stage(uniform_msk, surface_get_texture(_msk));
				
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
		
			BLEND_NORMAL;
		surface_reset_target();
		
		_outSurf = mask_apply(_data[0], _outSurf, _mask, _mix);
		
		return _outSurf;
	}
}