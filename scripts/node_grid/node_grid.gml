#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Grid", "Render Type > Toggle", "R", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[10].setValue((_n.inputs[10].getValue() + 1) % 5); });
	});
#endregion

function Node_Grid(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Grid";
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Vec2("Position", self, [ 0, 0 ]))
		.setUnitRef(function(index) { return getDimension(index); });
	
	newInput(2, nodeValue_Vec2("Grid Size", self, [ 8, 8 ]))
		.setMappable(13);
	
	newInput(3, nodeValue_Float("Gap", self, 0.2))
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 0.5, 0.001] })
		.setMappable(14);
	
	newInput(4, nodeValue_Rotation("Angle", self, 0))
		.setMappable(15);
		
	newInput(5, nodeValue_Gradient("Tile Color", self, new gradientObject(ca_white)))
		.setMappable(20);
		
	newInput(6, nodeValue_Color("Gap Color",  self, ca_black));
	
	newInput(7, nodeValue_Surface("Texture", self));
	
	newInput(8, nodeValue_Float("Shift", self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [-0.5, 0.5, 0.01] })
		.setMappable(16);
		
	newInput(9, nodeValue_Enum_Button("Shift Axis", self,  0, ["X", "Y"]));
		
	newInput(10, nodeValue_Enum_Scroll("Render Type", self,  0, ["Colored tile", "Colored tile (Accurate)", "Height map", "Texture grid", "Texture sample"]));
		
	newInput(11, nodeValueSeed(self));
	
	newInput(12, nodeValue_Bool("Anti-aliasing", self, false));
	
		newInput(13, nodeValueMap("Scale Map", self));
	
		newInput(14, nodeValueMap("Gap Map", self));
	
		newInput(15, nodeValueMap("Angle Map", self));
	
		newInput(16, nodeValueMap("Shift Map", self));
	
	newInput(17, nodeValue_Bool("Truchet", self, false));
	
	newInput(18, nodeValue_Int("Truchet Seed", self, seed_random()));
	
	newInput(19, nodeValue_Float("Flip Horizontal", self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider);
	
		newInput(20, nodeValueMap("Gradient Map", self));
	
		newInput(21, nodeValueGradientRange("Gradient Map Range", self, inputs[5]));
	
	newInput(22, nodeValue_Float("Flip Vertical", self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(23, nodeValue_Rotation_Range("Texture Angle", self, [ 0, 0 ]));
		
	newInput(24, nodeValue_Slider_Range("Level", self, [ 0, 1 ]));
	
	newInput(25, nodeValue_Bool("Use Texture Dimension", self, false));
	
	newInput(26, nodeValue_Float("Gap Width", self, 1));
	
	newInput(27, nodeValue_Bool("Diagonal", self, false));
	
	newInput(28, nodeValue_Bool("Uniform Gap", self, true));
	
	newInput(29, nodeValue_Float("Secondary Scale", self, 0));
	
	newInput(30, nodeValue_Float("Secondary Shift", self, 0))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(31, nodeValue_Float("Random Shift", self, 0))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(32, nodeValueSeed(self, VALUE_TYPE.float, "Shift Seed"));
	
	newInput(33, nodeValue_Float("Random Scale", self, 0))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(34, nodeValueSeed(self, VALUE_TYPE.float, "Scale Seed"));
	
	newInput(35, nodeValue_Surface("Mask", self));
	
	newInput(36, nodeValue_Bool("Invert Size", self, false));
	
	input_display_list = [
		["Output",    false],  0, 35, 
		["Pattern",	  false],  1,  4, 15, 36,  2, 13, 28,  3, 26, 27, 14, 
		["Shift",	  false],  9,  8, 16, 31, 32, 30, 
		["Scale",     false], 33, 34, 29, 
		["Render",	  false], 10, 11,  5, 20,  6,  7, 25, 12, 24, 
		["Truchet",    true, 17], 18, 19, 22, 23, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	attribute_interpolation();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {

		var pos = getSingleValue(1);
		
		InputDrawOverlay(inputs[ 1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[ 2].drawOverlay(w_hoverable, active, _x + pos[0] * _s, _y + pos[1] * _s, _s, _mx, _my, _snx, _sny, 1));
		InputDrawOverlay(inputs[ 4].drawOverlay(w_hoverable, active, _x + pos[0] * _s, _y + pos[1] * _s, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[21].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, getSingleValue(0)));
		
		return w_hovering;
	}
	
	static getDimension = function(_arr = 0) {
		var _dim = getSingleValue( 0, _arr);
		var _sam = getSingleValue( 7, _arr);
		var _mod = getSingleValue(10, _arr);
		var _txd = getSingleValue(25, _arr);
		var _tex = _mod == 3 || _mod == 4;
		
		if(is_surface(_sam) && _tex && _txd) 
			return surface_get_dimension(_sam);
		return _dim;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim  = surface_get_dimension(_outSurf);
		var _pos  = _data[ 1];
		var _sam  = _data[ 7];
		var _mode = _data[10];
		
		var _col_gap  = _data[6];
		var _tex_mode = _mode == 3 || _mode == 4;
		
		inputs[ 5].setVisible(_mode == 0 || _mode == 1);
		inputs[ 3].setVisible(_mode == 0 || _mode == 3 || _mode == 4);
		inputs[24].setVisible(_mode == 2);
		inputs[26].setVisible(_mode == 1);
		
		inputs[ 4].setVisible(_mode != 1);
		inputs[ 8].setVisible(_mode != 1);
		inputs[ 9].setVisible(_mode != 1);
		inputs[27].setVisible(_mode == 1);
		
		inputs[ 7].setVisible(_tex_mode, _tex_mode);
		inputs[25].setVisible(_tex_mode, _tex_mode);
		
		surface_set_shader(_outSurf, sh_grid);
		    shader_set_interpolation(_sam);
		    
			shader_set_f("position",	_pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_f("dimension",	_dim[0], _dim[1]);
			
			shader_set_f_map("scale",	_data[ 2], _data[13], inputs[2]);
			shader_set_f_map("width",	_data[ 3], _data[14], inputs[3]);
			shader_set_f_map("angle",	_data[ 4], _data[15], inputs[4]);
			shader_set_f_map("shift",	_data[ 8], _data[16], inputs[8]);
			
			shader_set_i("mode",           _mode);
			shader_set_i("scaleMode",      _data[36]);
			shader_set_f("seed",           _data[11]);
			shader_set_i("shiftAxis",      _data[ 9]);
			shader_set_i("aa",             _data[12]);
			shader_set_i("textureTruchet", _data[17]);
			shader_set_f("truchetSeed",    _data[18]);
			shader_set_f("truchetThresX",  _data[19]);
			shader_set_f("truchetThresY",  _data[22]);
			shader_set_2("truchetAngle",   _data[23]);
			shader_set_2("level",          _data[24]);
			shader_set_f("gapAcc",         _data[26]);
			shader_set_i("diagonal",       _data[27]);
			shader_set_i("uniformSize",    _data[28]);
			shader_set_f("secScale",       _data[29]);
			shader_set_f("secShift",       _data[30]);
			
			shader_set_f("randShift",     _data[31]);
			shader_set_f("randShiftSeed", _data[32]);
			shader_set_f("randScale",     _data[33]);
			shader_set_f("randScaleSeed", _data[34]);
			
			shader_set_color("gapCol", _col_gap);
			
			shader_set_gradient(_data[5], _data[20], _data[21], inputs[5]);
			
			if(is_surface(_sam))	draw_surface_stretched_safe(_sam, 0, 0, _dim[0], _dim[1]);
			else					draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
}