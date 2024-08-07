function Node_create_BW(_x, _y) {
	var node = new Node_BW(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_BW(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "BW";
	
	uniform_exp = shader_get_uniform(sh_bw, "brightness");
	uniform_con = shader_get_uniform(sh_bw, "contrast");
	
	inputs[| 0] = new NodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = new NodeValue_Float(1, "Brightness", self, 0);
	inputs[| 1].setDisplay(VALUE_DISPLAY.slider, [ -1, 1, 0.01]);
	
	inputs[| 2] = new NodeValue_Float(2, "Contrast",   self, 1);
	inputs[| 2].setDisplay(VALUE_DISPLAY.slider, [ -1, 4, 0.01]);
	
	outputs[| 0] = new nodeValue_Output(0, "Surface out", self, VALUE_TYPE.surface, surface_create(1, 1));
	
	function process_data(_inSurf, _outSurf, _data) {
		var _exp = _data[1];
		var _con = _data[2];
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		
		shader_set(sh_bw);
			shader_set_uniform_f(uniform_exp, _exp);
			shader_set_uniform_f(uniform_con, _con);
			draw_surface(_inSurf, 0, 0);
		shader_reset();
		surface_reset_target();
		
		return _outSurf;
	}
}