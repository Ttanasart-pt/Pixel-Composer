function Node_Grid_Noise(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Grid Noise";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 2] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 8, 8 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 4] = nodeValue("Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [-0.5, 0.5, 0.01] });
		
	inputs[| 5] = nodeValue("Texture sample", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 6] = nodeValue("Shift axis", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, ["x", "y"]);
	
	inputs[| 7] = nodeValue("Color mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Greyscale", "RGB", "HSV" ]);
	
	inputs[| 8] = nodeValue("Color R range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	inputs[| 9] = nodeValue("Color G range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	inputs[| 10] = nodeValue("Color B range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	input_display_list = [
		["Output",	false], 0,
		["Noise",	false], 3, 1, 2, 6, 4, 
		["Render",	false], 5, 7, 8, 9, 10, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _pos = _data[1];
		var _sca = _data[2];
		var _sed = _data[3];
		var _shf = _data[4];
		var _sam = _data[5];
		var _shfAx = _data[6];
		
		var _col = _data[ 7];
		var _clr = _data[ 8];
		var _clg = _data[ 9];
		var _clb = _data[10];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_grid_noise);
		shader_set_f("dimension", _dim);
		shader_set_f("position", _pos);
		shader_set_f("scale", _sca);
		shader_set_i("useSampler", is_surface(_sam));
		shader_set_f("shift", _shf);
		shader_set_i("shiftAxis", _shfAx);
		shader_set_f("seed", _sed);
			
		shader_set_i("colored", _col);
		shader_set_f("colorRanR", _clr);
		shader_set_f("colorRanG", _clg);
		shader_set_f("colorRanB", _clb);
		
		if(is_surface(_sam))
			draw_surface_stretched_safe(_sam, 0, 0, _dim[0], _dim[1]);
		else
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	}
}