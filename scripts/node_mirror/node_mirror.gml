function Node_Mirror(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Mirror";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 2] = nodeValue("Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 3] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 3;
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Mirror mask", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 3,
		["Surface",	 false], 0, 
		["Mirror",	 false], 1, 2, 
	]
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _pos   = inputs[| 1].getValue();
		var _ang   = inputs[| 2].getValue();
		var _posx = _pos[0] * _s + _x;
		var _posy = _pos[1] * _s + _y;
		
		var dx0 = _posx + lengthdir_x(1000, _ang);
		var dx1 = _posx + lengthdir_x(1000, _ang + 180);
		var dy0 = _posy + lengthdir_y(1000, _ang);
		var dy1 = _posy + lengthdir_y(1000, _ang + 180);
		
		draw_set_color(COLORS._main_accent);
		draw_line(dx0, dy0, dx1, dy1);
		
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[| 2].drawOverlay(active, _posx, _posy, _s, _mx, _my, _snx, _sny);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = [ surface_get_width(_data[0]), surface_get_height(_data[0]) ];
		var _pos = _data[1];
		var _ang = _data[2];
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_OVERRIDE;
			
			shader = _output_index? sh_mirror_mask : sh_mirror;
			uniform_dim = shader_get_uniform(shader, "dimension");
			uniform_pos = shader_get_uniform(shader, "position");
			uniform_ang = shader_get_uniform(shader, "angle");
	
			shader_set(shader);
			shader_set_uniform_f_array_safe(uniform_dim, _dim);
			shader_set_uniform_f_array_safe(uniform_pos, _pos);
			shader_set_uniform_f(uniform_ang, degtorad(_ang));
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
			
			BLEND_NORMAL;
		surface_reset_target();
		
		return _outSurf;
	}
}