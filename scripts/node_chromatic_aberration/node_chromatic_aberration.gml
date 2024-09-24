function Node_Chromatic_Aberration(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Chromatic Aberration";
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Vec2("Center", self, [ 0.5, 0.5 ]))
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
	
	newInput(2, nodeValue_Float("Strength", self, 1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [-16, 16, 0.01] })
		.setMappable(4);
	
	newInput(3, nodeValue_Bool("Active", self, true));
		active_index = 3;
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(4, nodeValueMap("Strength map", self));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(5, nodeValue_Enum_Scroll("Type", self, 0, [ "Spherical", "Scale" ]));
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 3, 
		["Surface",  false], 0, 
		["Effect",   false], 1, 2, 4, 
	];
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var pos  = getInputData(1);
		var px   = _x + pos[0] * _s;
		var py   = _y + pos[1] * _s;
		var _hov = false;
		
		var hv = inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
	
	static step = function() {
		inputs[2].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		
		surface_set_shader(_outSurf, sh_chromatic_aberration);
			shader_set_interpolation(    _data[0]);
			shader_set_dim("dimension",  _data[0]);
			// shader_set_i("type",         _data[5]);
			shader_set_2("center",       _data[1]);
			shader_set_f_map("strength", _data[2], _data[4], inputs[2]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		return _outSurf;
	}
}