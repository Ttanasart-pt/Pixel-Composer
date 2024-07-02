function Node_Noise_Aniso(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Anisotropic Noise";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("X Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2)
		.setMappable(6);
	
	inputs[| 2] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[| 2].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	inputs[| 3] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 4] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation)
		.setMappable(8);
	
	inputs[| 5] = nodeValue("Y Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 16)
		.setMappable(7);
		
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 6] = nodeValueMap("X Amount map", self);
	
	inputs[| 7] = nodeValueMap("Y Amount map", self);
	
	inputs[| 8] = nodeValueMap("Rotation map", self);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 9] = nodeValue("Render mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Blend", "Waterfall" ] )
		
	input_display_list = [
		["Output",	false], 0, 
		["Noise",	false], 2, 1, 6, 5, 7, 3, 4, 8, 
		["Render",	false], 9, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var  hv  = inputs[| 3].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
	
	static step = function() { #region
		inputs[| 1].mappableStep();
		inputs[| 4].mappableStep();
		inputs[| 5].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _pos = _data[3];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_ani_noise);
			shader_set_f("position",	_pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_f("seed",		_data[2]);
			
			shader_set_f_map("noiseX",  _data[1], _data[6], inputs[| 1]);
			shader_set_f_map("noiseY",  _data[5], _data[7], inputs[| 5]);
			shader_set_f_map("angle",	_data[4], _data[8], inputs[| 4]);
			
			shader_set_i("mode",		_data[9]);
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		
		return _outSurf;
	}
}