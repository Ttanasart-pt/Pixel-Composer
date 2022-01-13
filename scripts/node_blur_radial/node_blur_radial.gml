function Node_create_Blur_Radial(_x, _y) {
	var node = new Node_Blur_Radial(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Blur_Radial(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "Blur_Radial";
	
	uniform_str = shader_get_uniform(sh_blur_radial, "strength");
	uniform_cen = shader_get_uniform(sh_blur_radial, "center");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2);
	
	inputs[| 2] = nodeValue(2, "Center",   self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	static drawOverlay = function(_active, _x, _y, _s, _mx, _my) {
		var pos = inputs[| 2].getValue();
		var px = _x + pos[0] * _s;
		var py = _y + pos[1] * _s;
		
		inputs[| 1].drawOverlay(_active, px, py, _s, _mx, _my, 0, 64);
		inputs[| 2].drawOverlay(_active, _x, _y, _s, _mx, _my);
	}
	
	function process_data(_outSurf, _data, _output_index) {
		var _str = _data[1];
		var _cen = _data[2];
		_cen[0] /= surface_get_width(_outSurf);
		_cen[1] /= surface_get_height(_outSurf);
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_ADD
		
			shader_set(sh_blur_radial);
			shader_set_uniform_f(uniform_str, _str);
			shader_set_uniform_f_array(uniform_cen, _cen);
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
		
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}