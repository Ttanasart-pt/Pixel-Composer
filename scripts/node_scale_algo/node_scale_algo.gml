function Node_create_Scale_Algo(_x, _y, _group = noone, _param = "") {
	var node = new Node_Scale_Algo(_x, _y, _group);
	//ds_list_add(PANEL_GRAPH.nodes_list, node);
	
	switch(_param) {
		case "scale2x" : node.inputs[| 1].setValue(0); break;	
		case "scale3x" : node.inputs[| 1].setValue(1); break;	
	}
	
	return node;
}

function Node_Scale_Algo(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Scale Algorithm";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Algorithm", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Scale2x", "Scale3x" ]);
		
	inputs[| 2] = nodeValue("Tolerance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 3] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 3;
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 3,
		["Surface",	 false], 0, 
		["Scale",	 false], 1, 2, 
	]
	
	attribute_surface_depth();
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var inSurf = _data[0];
		var algo   = _data[1];
		var ww     = surface_get_width(inSurf);
		var hh     = surface_get_height(inSurf);
		var cDep   = attrDepth();
		var shader;
		var sc = 2;
		
		switch(algo) {
			case 0 :
				shader = sh_scale2x;
				sc = 2;
				var sw = ww * 2;
				var sh = hh * 2;
				
				_outSurf = surface_verify(_outSurf, sw, sh, cDep);
				break;
			case 1 :
				shader = sh_scale3x;
				sc = 3;
				var sw = ww * 3;
				var sh = hh * 3;
				
				_outSurf = surface_verify(_outSurf, sw, sh, cDep);
				break;
			default: return _outSurf;
		}
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
		
		var uniform_dim = shader_get_uniform(shader, "dimension");
		var uniform_tol = shader_get_uniform(shader, "tol");
		
		shader_set(shader);
			shader_set_uniform_f_array_safe(uniform_dim, [ ww, hh ]);
			shader_set_uniform_f(uniform_tol, _data[2]);
			draw_surface_ext_safe(_data[0], 0, 0, sc, sc, 0, c_white, 1);
		shader_reset();
		
		BLEND_NORMAL;
		surface_reset_target();
		
		return _outSurf;
	}
}