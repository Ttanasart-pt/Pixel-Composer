function Node_Repeat_Texture(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Repeat Texture";
	dimension_index = 1;
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| 1] = nodeValue("Target dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 2] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Tile", "Scatter", "Cell" ]);
	
	inputs[| 3] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[| 3].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) })
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 3, 
		["Surfaces",	false], 0, 
		["Repeat",		false], 1, 2,
	];
	
	attribute_surface_depth();
		
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		var _dim  = _data[1];
		var _type = _data[2];
		var _seed = _data[3];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		if(!is_surface(_surf)) return _outSurf;
		
		var _sdim = surface_get_dimension(_surf);
		
		gpu_set_texrepeat(1);
		surface_set_shader(_outSurf, sh_texture_repeat);
			shader_set_f("seed",    		 _seed);
			shader_set_f("dimension",        _dim);
			shader_set_f("surfaceDimension", _sdim);
			shader_set_surface("surface",    _surf);
			shader_set_i("type",             _type);
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		gpu_set_texrepeat(0);
		
		return _outSurf;
	}
}