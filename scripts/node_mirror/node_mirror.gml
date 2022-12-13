function Node_Mirror(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Mirror";
	
	uniform_dim = shader_get_uniform(sh_mirror, "dimension");
	uniform_pos = shader_get_uniform(sh_mirror, "position");
	uniform_ang = shader_get_uniform(sh_mirror, "angle");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue(2, "Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my) {
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
		
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my);
		inputs[| 2].drawOverlay(active, _posx, _posy, _s, _mx, _my);
	}
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _dim = [ surface_get_width(_data[0]), surface_get_height(_data[0]) ];
		var _pos = _data[1];
		var _ang = _data[2];
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_ADD
			
			shader_set(sh_mirror);
			shader_set_uniform_f_array(uniform_dim, _dim);
			shader_set_uniform_f_array(uniform_pos, _pos);
			shader_set_uniform_f(uniform_ang, degtorad(_ang));
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
			
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}