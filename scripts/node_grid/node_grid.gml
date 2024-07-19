function Node_Grid(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Grid";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 2] = nodeValue("Grid Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 8, 8 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setMappable(13);
	
	inputs[| 3] = nodeValue("Gap", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 0.5, 0.001] })
		.setMappable(14);
	
	inputs[| 4] = nodeValue("Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation)
		.setMappable(15);
		
	inputs[| 5] = nodeValue("Tile color", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(c_white) )
		.setMappable(20);
		
	inputs[| 6] = nodeValue("Gap color",  self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 7] = nodeValue("Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 8] = nodeValue("Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [-0.5, 0.5, 0.01] })
		.setMappable(16);
		
	inputs[| 9] = nodeValue("Shift axis", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, ["X", "Y"]);
		
	inputs[| 10] = nodeValue("Render type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Colored tile", "Colored tile (Accurate)", "Height map", "Texture grid", "Texture sample"]);
		
	inputs[| 11] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[| 11].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	inputs[| 12] = nodeValue("Anti aliasing", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
		inputs[| 13] = nodeValueMap("Scale map", self);
	
		inputs[| 14] = nodeValueMap("Gap map", self);
	
		inputs[| 15] = nodeValueMap("Angle map", self);
	
		inputs[| 16] = nodeValueMap("Shift map", self);
	
	inputs[| 17] = nodeValue("Truchet", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 18] = nodeValue("Truchet seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, seed_random());
	
	inputs[| 19] = nodeValue("Flip horizontal", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
	
		inputs[| 20] = nodeValueMap("Gradient map", self);
	
		inputs[| 21] = nodeValueGradientRange("Gradient map range", self, inputs[| 5]);
	
	inputs[| 22] = nodeValue("Flip vertical", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 23] = nodeValue("Texture angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.rotation_range);
		
	inputs[| 24] = nodeValue("Level", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	inputs[| 25] = nodeValue("Use Texture Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 26] = nodeValue("Gap Width", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 27] = nodeValue("Diagonal", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 28] = nodeValue("Uniform height", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	input_display_list = [
		["Output",  false], 0,
		["Pattern",	false], 1, 4, 15, 2, 13, 28, 3, 26, 27, 14, 9, 8, 16,
		["Render",	false], 10, 11, 5, 20, 6, 7, 25, 12, 24, 
		["Truchet",  true, 17], 18, 19, 22, 23, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var hov = false;
		var pos = getSingleValue(1);
		
		var hv = inputs[|  1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);                      			active &= !hv; hov |= bool(hv);
		var hv = inputs[|  2].drawOverlay(hover, active, _x + pos[0] * _s, _y + pos[1] * _s, _s, _mx, _my, _snx, _sny, 1);	active &= !hv; hov |= bool(hv);
		var hv = inputs[|  4].drawOverlay(hover, active, _x + pos[0] * _s, _y + pos[1] * _s, _s, _mx, _my, _snx, _sny);     active &= !hv; hov |= bool(hv);
		var hv = inputs[| 21].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, getSingleValue(0));				active &= !hv; hov |= bool(hv);
		
		return hov;
	}
	
	static step = function() { #region
		inputs[| 2].mappableStep();
		inputs[| 3].mappableStep();
		inputs[| 4].mappableStep();
		inputs[| 5].mappableStep();
		inputs[| 8].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim  = _data[ 0];
		var _pos  = _data[ 1];
		var _sam  = _data[ 7];
		var _mode = _data[10];
		
		var _col_gap  = _data[6];
		var _tex_mode = _mode == 3 || _mode == 4;
		
		inputs[|  5].setVisible(_mode == 0 || _mode == 1);
		inputs[|  3].setVisible(_mode == 0 || _mode == 3 || _mode == 4);
		inputs[| 24].setVisible(_mode == 2);
		inputs[| 26].setVisible(_mode == 1);
		
		inputs[|  4].setVisible(_mode != 1);
		inputs[|  8].setVisible(_mode != 1);
		inputs[|  9].setVisible(_mode != 1);
		inputs[| 27].setVisible(_mode == 1);
		
		inputs[|  7].setVisible(_tex_mode, _tex_mode);
		inputs[| 25].setVisible(_tex_mode, _tex_mode);
		
		var _tex_dim = is_surface(_sam) && _tex_mode && _data[25];
		if(_tex_dim) _dim = surface_get_dimension(_sam);
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_grid);
			shader_set_f("position",	_pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_f("dimension",	_dim[0], _dim[1]);
			
			shader_set_f_map("scale",	_data[ 2], _data[13], inputs[| 2]);
			shader_set_f_map("width",	_data[ 3], _data[14], inputs[| 3]);
			shader_set_f_map("angle",	_data[ 4], _data[15], inputs[| 4]);
			shader_set_f_map("shift",	_data[ 8], _data[16], inputs[| 8]);
			
			shader_set_i("mode",		   _mode);
			shader_set_f("seed", 		   _data[11]);
			shader_set_i("shiftAxis",	   _data[ 9]);
			shader_set_i("aa",			   _data[12]);
			shader_set_i("textureTruchet", _data[17]);
			shader_set_f("truchetSeed",    _data[18]);
			shader_set_f("truchetThresX",  _data[19]);
			shader_set_f("truchetThresY",  _data[22]);
			shader_set_2("truchetAngle",   _data[23]);
			shader_set_2("level",          _data[24]);
			shader_set_f("gapAcc",         _data[26]);
			shader_set_i("diagonal",       _data[27]);
			shader_set_i("uniformSize",    _data[28]);
			
			shader_set_color("gapCol",  _col_gap);
			
			shader_set_gradient(_data[5], _data[20], _data[21], inputs[| 5]);
			
			if(is_surface(_sam))	draw_surface_stretched_safe(_sam, 0, 0, _dim[0], _dim[1]);
			else					draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	}
}