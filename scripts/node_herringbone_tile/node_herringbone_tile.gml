function Node_Herringbone_Tile(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Herringbone Tile";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 2] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 4, 4 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setMappable(11);
	
	inputs[| 3] = nodeValue("Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation)
		.setMappable(12);
	
	inputs[| 4] = nodeValue("Gap", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.25)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 0.5, 0.001] })
		.setMappable(13);
	
	inputs[| 5] = nodeValue("Tile color", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(cola(c_white)) )
		.setMappable(18);
	
	inputs[| 6] = nodeValue("Gap color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 7] = nodeValue("Render type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Colored tile", "Height map", "Texture grid"]);
		
	inputs[| 8] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[| 8].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
		
	inputs[| 9] = nodeValue("Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 10] = nodeValue("Anti aliasing", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 11] = nodeValueMap("Scale map", self);
	
	inputs[| 12] = nodeValueMap("Angle map", self);
	
	inputs[| 13] = nodeValueMap("Gap map", self);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 14] = nodeValue("Truchet", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 15] = nodeValue("Truchet seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, seed_random());
	
	inputs[| 16] = nodeValue("Truchet threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider)
		
	inputs[| 17] = nodeValue("Tile length", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2);
		
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 18] = nodeValueMap("Gradient map", self);
	
	inputs[| 19] = nodeValueGradientRange("Gradient map range", self, inputs[| 5]);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 20] = nodeValue("Texture angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.rotation_range);
			
	inputs[| 21] = nodeValue("Level", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	input_display_list = [
		["Output",  false], 0,
		["Pattern",	false], 1, 3, 12, 2, 11, 17, 4, 13,
		["Render",	false], 7, 8, 5, 18, 6, 9, 10, 21, 
		["Truchet",  true, 14], 15, 16, 20, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var  hv  = inputs[| 1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);					 active &= !hv; _hov |= hv;
		var  hv  = inputs[| 19].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, getSingleValue(0)); active &= !hv; _hov |= hv;
		
		return _hov;
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
		var _sam  = _data[9];
		var _mode = _data[7];
		
		var _col_gap = _data[6];
		
		inputs[|  5].setVisible(_mode == 0);
		inputs[|  6].setVisible(_mode != 1);
		inputs[| 21].setVisible(_mode == 1);
		inputs[|  9].setVisible(_mode == 2 || _mode == 3);
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_herringbone_tile);
			shader_set_f("dimension", _dim[0], _dim[1]);
			shader_set_f("position",  _pos[0] / _dim[0], _pos[1] / _dim[1]);
			
			shader_set_f_map("scale", _data[ 2], _data[11], inputs[| 2]);
			shader_set_f_map("angle", _data[ 3], _data[12], inputs[| 3]);
			shader_set_f_map("thick", _data[ 4], _data[13], inputs[| 4]);
			
			shader_set_f("seed",  _data[ 8]);
			shader_set_i("mode",  _mode);
			shader_set_i("aa",    _data[10]);
			shader_set_f("tileLength", _data[17]);
			shader_set_color("gapCol", _col_gap);
			
			shader_set_i("textureTruchet", _data[14]);
			shader_set_f("truchetSeed",    _data[15]);
			shader_set_f("truchetThres",   _data[16]);
			shader_set_2("truchetAngle",   _data[20]);
			shader_set_2("level",          _data[21]);
			
			shader_set_gradient(_data[5], _data[18], _data[19], inputs[| 5]);
			
			if(is_surface(_sam)) draw_surface_stretched_safe(_sam, 0, 0, _dim[0], _dim[1]);
			else                 draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	}
}