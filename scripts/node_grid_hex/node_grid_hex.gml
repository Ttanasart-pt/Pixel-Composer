function Node_Grid_Hex(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Hexagonal Grid";
	
	inputs[| 0] = nodeValue_Dimension(self);
	
	inputs[| 1] = nodeValue_Vector("Position", self, [ 0, 0 ])
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 2] = nodeValue_Vector("Scale", self, [ 2, 2 ])
		.setMappable(11);
	
	inputs[| 3] = nodeValue_Rotation("Angle", self, 0)
		.setMappable(12);
	
	inputs[| 4] = nodeValue_Float("Gap", self, 0.1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 0.5, 0.001] })
		.setMappable(13);
	
	inputs[| 5] = nodeValue_Gradient("Tile color", self, new gradientObject(cola(c_white)))
		.setMappable(17);
	
	inputs[| 6] = nodeValue_Color("Gap color", self, c_black);
	
	inputs[| 7] = nodeValue_Enum_Scroll("Render type", self,  0, ["Colored tile", "Height map", "Texture grid", "Texture sample"]);
		
	inputs[| 8] = nodeValue_Float("Seed", self, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[| 8].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
		
	inputs[| 9] = nodeValue_Surface("Texture", self);
	
	inputs[| 10] = nodeValue_Bool("Anti aliasing", self, false);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 11] = nodeValueMap("Scale map", self);
	
	inputs[| 12] = nodeValueMap("Angle map", self);
	
	inputs[| 13] = nodeValueMap("Gap map", self);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 14] = nodeValue_Bool("Truchet", self, false);
	
	inputs[| 15] = nodeValue_Int("Truchet seed", self, seed_random());
	
	inputs[| 16] = nodeValue_Float("Truchet threshold", self, 0.5)
		.setDisplay(VALUE_DISPLAY.slider)
		
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 17] = nodeValueMap("Gradient map", self);
	
	inputs[| 18] = nodeValueGradientRange("Gradient map range", self, inputs[| 5]);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 19] = nodeValue_Rotation_Range("Texture angle", self, [ 0, 0 ]);
		
	inputs[| 20] = nodeValue_Slider_Range("Level", self, [ 0, 1 ]);
	
	inputs[| 21] = nodeValue_Bool("Use Texture Dimension", self, true);
	
	input_display_list = [
		["Output",  false], 0,
		["Pattern",	false], 1, 3, 12, 2, 11, 4, 13,
		["Render",	false], 7, 8, 5, 17, 6, 9, 21, 10, 20, 
		["Truchet",  true, 14], 15, 16, 19, 
	];
	
	outputs[| 0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var a = inputs[|  1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);						active &= !a; _hov |= a;
		var a = inputs[| 18].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, getSingleValue(0));	active &= !a; _hov |= a;
		
		return _hov;
	}
	
	static step = function() {
		inputs[| 2].mappableStep();
		inputs[| 3].mappableStep();
		inputs[| 4].mappableStep();
		inputs[| 5].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim  = _data[0];
		var _pos  = _data[1];
		var _sam  = _data[9];
		var _mode = _data[7];
		
		var _col_gap  = _data[6];
		var _tex_mode = _mode == 2 || _mode == 3;
		
		inputs[|  5].setVisible(_mode == 0);
		inputs[|  6].setVisible(_mode != 1);
		inputs[| 20].setVisible(_mode == 1);
		
		inputs[|  9].setVisible(_tex_mode, _tex_mode);
		inputs[| 21].setVisible(_tex_mode, _tex_mode);
		
		var _tex_dim = is_surface(_sam) && _tex_mode && _data[21];
		if(_tex_dim) _dim = surface_get_dimension(_sam);
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_grid_hex);
			shader_set_f("dimension", _dim[0], _dim[1]);
			shader_set_f("position",  _pos[0] / _dim[0], _pos[1] / _dim[1]);
			
			shader_set_f_map("scale", _data[ 2], _data[11], inputs[| 2]);
			shader_set_f_map("angle", _data[ 3], _data[12], inputs[| 3]);
			shader_set_f_map("thick", _data[ 4], _data[13], inputs[| 4]);
			
			shader_set_f("seed",  _data[ 8]);
			shader_set_i("mode",  _mode);
			shader_set_i("aa",    _data[10]);
			shader_set_color("gapCol",_col_gap);
			
			shader_set_i("textureTruchet", _data[14]);
			shader_set_f("truchetSeed",    _data[15]);
			shader_set_f("truchetThres",   _data[16]);
			shader_set_2("truchetAngle",   _data[19]);
			shader_set_2("level",          _data[20]);
			
			shader_set_gradient(_data[5], _data[17], _data[18], inputs[| 5]);
			
			if(is_surface(_sam)) draw_surface_stretched_safe(_sam, 0, 0, _dim[0], _dim[1]);
			else                 draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	}
}