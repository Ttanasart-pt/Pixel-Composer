function Node_Box_Pattern(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Box Pattern";
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Float("Scale", self, 2))
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.1] })
		.setMappable(6);
	
	newInput(2, nodeValue_Rotation("Angle", self, 0))
		.setMappable(7);
	
	newInput(3, nodeValue_Vec2("Position", self, [0, 0] ))
		.setUnitRef(function(index) { return getDimension(index); });
	
	newInput(4, nodeValue_Color("Color 1", self, c_white));
	
	newInput(5, nodeValue_Color("Color 2", self, c_black));
	
	//////////////////////////////////////////////////////////////////////////////////
	
	newInput(6, nodeValueMap("Amount map", self));
	
	newInput(7, nodeValueMap("Angle map", self));
	
	//////////////////////////////////////////////////////////////////////////////////
	
	newInput(8, nodeValue_Enum_Button("Type", self,  0, [ "Solid", "Smooth", "AA" ]));
	
	newInput(9, nodeValue_Float("Width", self, 0.25))
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(10);
	
	newInput(10, nodeValueMap("Width map", self));
	
	newInput(11, nodeValue_Enum_Button("Pattern", self,  0, [ "Cross", "Xor" ]));
	
	newInput(12, nodeValue_Int("Iteration", self, 4))
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Output",	true],	0,  
		["Pattern",	false], 11, 1, 6, 2, 7, 3, 9, 10, 12, 
		["Render",	false], 8, 4, 5,
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var pos  = getInputData(3);
		var px   = _x + pos[0] * _s;
		var py   = _y + pos[1] * _s;
		var _hov = false;
		
		var hv = inputs[3].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		var hv = inputs[2].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
	
	static step = function() { #region
		var _pat = getSingleValue(11);
		inputs[ 9].setVisible(_pat == 0);
		inputs[12].setVisible(_pat == 1);
		
		inputs[1].mappableStep();
		inputs[2].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _pos = _data[3];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
			
		surface_set_shader(_outSurf, sh_box_pattern);
			shader_set_f("dimension",   surface_get_width_safe(_outSurf), surface_get_height_safe(_outSurf));
			shader_set_f("position",   _pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_f_map("amount", _data[1], _data[ 6], inputs[1]);
			shader_set_f_map("angle",  _data[2], _data[ 7], inputs[2]);
			shader_set_f_map("width",  _data[9], _data[10], inputs[9]);
			shader_set_color("col1",   _data[4]);
			shader_set_color("col2",   _data[5]);
			shader_set_i("blend",	   _data[8]);
			shader_set_i("pattern",	   _data[11]);
			shader_set_i("iteration",  _data[12]);
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	}
}