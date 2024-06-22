function Node_Grid_Pentagonal(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Pentagonal Grid";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 2] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 4, 4 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setMappable(11);
	
	inputs[| 3] = nodeValue("Gap", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 0.5, 0.001] })
		.setMappable(12);
	
	inputs[| 4] = nodeValue("Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation)
		.setMappable(13);
		
	inputs[| 5] = nodeValue("Tile color", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(c_white) )
		.setMappable(14);
		
	inputs[| 6] = nodeValue("Gap color",  self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 7] = nodeValue("Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 8] = nodeValue("Render type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Colored tile", "Height map", "Texture grid"]);
		
	inputs[| 9] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[| 9].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	inputs[| 10] = nodeValue("Anti aliasing", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	/////////////////////////////////////////////////////////////////////
	
		inputs[| 11] = nodeValueMap("Scale map", self);
	
		inputs[| 12] = nodeValueMap("Gap map", self);
	
		inputs[| 13] = nodeValueMap("Angle map", self);
	
		inputs[| 14] = nodeValueMap("Gradient map", self);
	
		inputs[| 15] = nodeValueGradientRange("Gradient map range", self, inputs[| 5]);
	
	/////////////////////////////////////////////////////////////////////
	
	inputs[| 16] = nodeValue("Level", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	inputs[| 17] = nodeValue("Use Texture Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	input_display_list = [
		["Output",  false], 0,
		["Pattern",	false], 1, 4, 13, 2, 11, 3, 12, 
		["Render",	false], 8, 9, 5, 14, 6, 7, 17, 10, 16, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var a = inputs[| 1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); active &= !a;
		var a = inputs[| 15].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, getSingleValue(0)); active &= !a;
	}
	
	static step = function() { #region
		inputs[| 2].mappableStep();
		inputs[| 3].mappableStep();
		inputs[| 4].mappableStep();
		inputs[| 5].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim  = _data[0];
		var _pos  = _data[1];
		var _sam  = _data[7];
		var _mode = _data[8];
		
		var _col_gap  = _data[6];
		var _tex_mode = _mode == 2 || _mode == 3;
		
		inputs[|  5].setVisible(_mode == 0);
		inputs[|  6].setVisible(_mode != 1);
		inputs[| 16].setVisible(_mode == 1);
		
		inputs[|  7].setVisible(_tex_mode, _tex_mode);
		inputs[| 17].setVisible(_tex_mode, _tex_mode);
		
		var _tex_dim = is_surface(_sam) && _tex_mode && _data[17];
		if(_tex_dim) _dim = surface_get_dimension(_sam);
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		surface_set_shader(_outSurf, sh_grid_pentagonal);
			shader_set_f("position",	_pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_f("dimension",	_dim[0], _dim[1]);
			
			shader_set_f_map("scale",	_data[ 2], _data[11], inputs[| 2]);
			shader_set_f_map("width",	_data[ 3], _data[12], inputs[| 3]);
			shader_set_f_map("angle",	_data[ 4], _data[13], inputs[| 4]);
			
			shader_set_i("mode",	_mode);
			shader_set_f("seed", 	_data[ 9]);
			shader_set_i("aa",		_data[10]);
			shader_set_f("level",   _data[16]);
			
			shader_set_color("gapCol",  _col_gap);
			
			shader_set_gradient(_data[5], _data[14], _data[15], inputs[| 5]);
			
			if(is_surface(_sam))	draw_surface_stretched_safe(_sam, 0, 0, _dim[0], _dim[1]);
			else					draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	}
}