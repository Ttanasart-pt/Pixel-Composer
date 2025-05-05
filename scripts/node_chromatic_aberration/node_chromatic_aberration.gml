function Node_Chromatic_Aberration(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Chromatic Aberration";
	
	newActiveInput(3);
	newInput(5, nodeValue_Enum_Button("Type",      self, 0, [ "RGB", "Continuous" ]));
	newInput(0, nodeValue_Surface( "Surface In",   self));
	newInput(1, nodeValue_Vec2(    "Center",       self, [ 0.5, 0.5 ])).setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	newInput(2, nodeValue_Slider(  "Strength",     self, 1, { range: [-16, 16, 0.01] })).setMappable(4);
	newInput(4, nodeValueMap(      "Strength map", self));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 3, 
		["Surface",  false], 0, 
		["Effect",   false], 5, 1, 2, 4, 
	];
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {

		
		var hv = inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny); OVERLAY_HV
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		inputs[2].mappableStep();
		
		var _surf = _data[0];
		var _cent = _data[1];
		var _type = _data[5];
		
		surface_set_shader(_outSurf, sh_chromatic_aberration);
			shader_set_interpolation(    _surf);
			shader_set_dim("dimension",  _surf);
			shader_set_i("type",         _type);
			shader_set_2("center",       _cent);
			shader_set_f_map("strength", _data[2], _data[4], inputs[2]);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		return _outSurf;
	}
}