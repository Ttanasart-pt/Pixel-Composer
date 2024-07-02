function Node_Chromatic_Aberration(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Chromatic Aberration";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Center", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0.5, 0.5 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
	
	inputs[| 2] = nodeValue("Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [-16, 16, 0.01] })
		.setMappable(4);
	
	inputs[| 3] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 3;
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 4] = nodeValueMap("Strength map", self);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 3, 
		["Surface",  false], 0, 
		["Effect",   false], 1, 2, 4, 
	]
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var pos  = getInputData(1);
		var px   = _x + pos[0] * _s;
		var py   = _y + pos[1] * _s;
		var _hov = false;
		
		var hv = inputs[| 1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	} #endregion
	
	static step = function() { #region
		inputs[| 2].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		
		surface_set_shader(_outSurf, sh_chromatic_aberration);
		shader_set_interpolation(_data[0]);
			shader_set_f("dimension", surface_get_width_safe(_data[0]), surface_get_height_safe(_data[0]));
			shader_set_2("center",       _data[1]);
			shader_set_f_map("strength", _data[2], _data[4], inputs[| 2]);
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}