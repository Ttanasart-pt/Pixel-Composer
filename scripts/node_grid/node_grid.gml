function Node_Grid(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Grid";
	
	shader = sh_grid;
	uniform_pos = shader_get_uniform(shader, "position");
	uniform_dim = shader_get_uniform(shader, "dimension");
	uniform_sca = shader_get_uniform(shader, "scale");
	uniform_wid = shader_get_uniform(shader, "width");
	uniform_ang = shader_get_uniform(shader, "angle");
	uniform_shf = shader_get_uniform(shader, "shift");
	uniform_shx = shader_get_uniform(shader, "shiftAxis");
	uniform_hgt = shader_get_uniform(shader, "height");
	
	uniform_col1 = shader_get_uniform(shader, "col1");
	uniform_col2 = shader_get_uniform(shader, "col2");
	uniform_sam = shader_get_uniform(shader, "useSampler");
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 2] = nodeValue("Tiling", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 4, 4 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Gap", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 0.5, 0.01]);
	
	inputs[| 4] = nodeValue("Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
		
	inputs[| 5] = nodeValue("Color 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	inputs[| 6] = nodeValue("Color 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 7] = nodeValue("Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 8] = nodeValue("Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [-0.5, 0.5, 0.01]);
		
	inputs[| 9] = nodeValue("Shift axis", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, ["X", "Y"]);
		
	inputs[| 10] = nodeValue("Height", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	input_display_list = [
		["Output",  false], 0,
		["Pattern",	false], 1, 4, 2, 3, 9, 8,
		["Render",	false], 5, 6, 7, 10
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _pos = _data[1];
		var _sca = _data[2];
		var _wid = _data[3];
		var _ang = _data[4];
		var _sam = _data[7];
		var _shf = _data[8];
		var _shx = _data[9];
		var _hgt = _data[10];
		
		var _col1 = _data[5];
		var _col2 = _data[6];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		shader_set(shader);
			shader_set_uniform_f(uniform_pos, _pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_uniform_f(uniform_dim, _dim[0], _dim[1]);
			shader_set_uniform_f_array_safe(uniform_sca, _sca);
			shader_set_uniform_f(uniform_wid, _wid);
			shader_set_uniform_f(uniform_ang, degtorad(_ang));
			shader_set_uniform_f(uniform_sam, is_surface(_sam));
			shader_set_uniform_f(uniform_shf, _shx? _shf / _sca[1] : _shf / _sca[0]);
			shader_set_uniform_i(uniform_shx, _shx);
			shader_set_uniform_i(uniform_hgt, _hgt);
			shader_set_uniform_f_array_safe(uniform_col1, colToVec4(_col1));
			shader_set_uniform_f_array_safe(uniform_col2, colToVec4(_col2));
			
			if(is_surface(_sam))
				draw_surface_stretched(_sam, 0, 0, _dim[0], _dim[1]);
			else
				draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		shader_reset();
		surface_reset_target();
		
		return _outSurf;
	}
}