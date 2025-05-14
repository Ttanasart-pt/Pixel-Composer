function Node_Skew(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Skew";
	
	newActiveInput(8);
	newInput(9, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- Surfaces
	
	newInput(0, nodeValue_Surface( "Surface In", self));
	newInput(6, nodeValue_Surface( "Mask",       self));
	newInput(7, nodeValue_Slider(  "Mix",        self, 1));
	__init_mask_modifier(6, 10); // inputs 10, 11
	
	////- Skew
	
	newInput( 1, nodeValue_Enum_Button( "Axis",            self, 0, ["x", "y"]));
	newInput( 2, nodeValue_Slider(      "Strength",        self, 0, [-1, 1, 0.01])).setMappable(12);
	newInput(12, nodeValueMap(          "Strength map",    self));
	newInput( 4, nodeValue_Vec2(        "Center",          self, [.5, .5])).setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	newInput( 3, nodeValue_Bool(        "Wrap",            self, false));
	newInput( 5, nodeValue_Enum_Scroll( "Oversample mode", self, 0, [ "Empty", "Clamp", "Repeat" ]));
	
	// inputs 13
	
	input_display_list = [ 8, 9, 
		["Surfaces", true],	0, 6, 7, 10, 11, 
		["Skew",	false],	1, 2, 12, 4,
	]
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	static centerAnchor = function() {
		if(!is_surface(current_data[0])) return;
		var ww = surface_get_width_safe(current_data[0]);
		var hh = surface_get_height_safe(current_data[0]);
		
		inputs[4].setValue([ww / 2, hh / 2]);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		InputDrawOverlay(inputs[4].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _samp = getAttribute("oversample");
		
		var _surf = _data[0];
		var _axis = _data[1];
		var _cent = _data[4];
		
		surface_set_shader(_outSurf, sh_skew);
		shader_set_interpolation(_surf);
			shader_set_dim("dimension",	_surf);
			shader_set_2("center",		_cent);
			shader_set_i("axis",		_axis);
			shader_set_f_map("amount",  _data[2], _data[12], inputs[2]);
			shader_set_i("sampleMode",	_samp);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[6], _data[7]);
		_outSurf = channel_apply(_surf, _outSurf, _data[9]);
		
		return _outSurf;
	}
}