function Node_create_Solid(_x, _y) {
	var node = new Node_Solid(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Solid(_x, _y) : Node(_x, _y) constructor {
	name = "Solid";
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2, VALUE_TAG.dimension_2d )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	inputs[| 2] = nodeValue(2, "Empty", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 3] = nodeValue(3, "Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	input_display_list = [
		0, 3, 1, 2
	];
	
	static update = function() {
		var _dim = inputs[| 0].getValue();
		var _col = inputs[| 1].getValue();
		var _emp = inputs[| 2].getValue();
		var _msk = inputs[| 3].getValue();
		
		var _outSurf = outputs[| 0].getValue();
		if(!is_surface(_outSurf)) {
			_outSurf = surface_create_valid(_dim[0], _dim[1]);
			outputs[| 0].setValue(_outSurf);
		} else
			surface_size_to(_outSurf, _dim[0], _dim[1]);
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			
			if(!_emp) {
				shader_set(sh_solid);
				if(is_surface(_msk))
					draw_surface_stretched_ext(_msk, 0, 0, _dim[0], _dim[1], _col, 1);
				else
					draw_sprite_stretched_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], _col, 1);
				shader_reset();
			}
		surface_reset_target();
	}
	doUpdate();
}