function Node_create_Scale_Algo(_x, _y, _group = -1, _param = "") {
	var node = new Node_Scale_Algo(_x, _y, _group);
	//ds_list_add(PANEL_GRAPH.nodes_list, node);
	
	switch(_param) {
		case "scale2x" : node.inputs[| 1].setValue(0); break;	
		case "scale3x" : node.inputs[| 1].setValue(1); break;	
	}
	
	return node;
}

function Node_Scale_Algo(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Scale Algo";
	
	uniform_dim = shader_get_uniform(sh_scale2x, "dimension");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Algorithm", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Scale2x", "Scale3x" ]);
		
	inputs[| 2] = nodeValue(2, "Tolerance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static process_data = function(_outSurf, _data, _output_index) {
		var inSurf = _data[0];
		var algo = _data[1];
		var ww = surface_get_width(inSurf);
		var hh = surface_get_height(inSurf);
		var shader = sh_scale2x;
		var sc = 2;
		
		switch(algo) {
			case 0 :
				shader = sh_scale2x;
				sc = 2;
				var sw = ww * 2;
				var sh = hh * 2;
				surface_size_to(_outSurf, sw, sh);
				break;
			case 1 :
				shader = sh_scale3x;
				sc = 3;
				var sw = ww * 3;
				var sh = hh * 3;
				surface_size_to(_outSurf, sw, sh);
				break;
		}
		
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_ADD
		
		uniform_dim = shader_get_uniform(shader, "dimension");
		uniform_tol = shader_get_uniform(shader, "tol");
		
		shader_set(shader);
			shader_set_uniform_f_array(uniform_dim, [ ww, hh ]);
			shader_set_uniform_f(uniform_tol, _data[2]);
			draw_surface_ext_safe(_data[0], 0, 0, sc, sc, 0, c_white, 1);
		shader_reset();
		
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}