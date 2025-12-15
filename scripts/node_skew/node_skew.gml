function Node_Skew(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Skew";
	
	newActiveInput(8);
	newInput(9, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(6, nodeValue_Surface( "Mask"       ));
	newInput(7, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(6, 10); // inputs 10, 11
	
	////- =Skew
	newInput( 5, nodeValue_EScroll( "Oversample mode", 0, [ "Empty", "Clamp", "Repeat" ]));
	newInput( 1, nodeValue_EButton( "Axis",       0, ["X", "Y"] ));
	newInput( 2, nodeValue_Slider(  "Strength",   0, [-1, 1, 0.01] )).setMappable(12).setCurvable(13);
	newInput( 4, nodeValue_Vec2(    "Center",   [.5,.5] )).setHotkey("G").setUnitSimple();
	newInput( 3, nodeValue_Bool(    "Wrap",      false  ));
	// inputs 14
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 8, 9, 
		[ "Surfaces", true ],  0,  6,  7, 10, 11, 
		[ "Skew",    false ],  1,  2, 12, 13,  4,
	];
	
	////- Nodes
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	static centerAnchor = function() {
		if(!is_surface(current_data[0])) return;
		var ww = surface_get_width_safe(current_data[0]);
		var hh = surface_get_height_safe(current_data[0]);
		
		inputs[4].setValue([ww / 2, hh / 2]);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _axis = getSingleValue(1);
		var _cent = getSingleValue(4);
		var _cx = _x + _cent[0] * _s;
		var _cy = _y + _cent[1] * _s;
		
		var _dim = getDimension();
		
		InputDrawOverlay(inputs[4].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny, _axis * 90, _dim[0] / 2, 2));
		
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
			shader_set_f_map("amount",  _data[2], _data[12], inputs[2], _data[13]);
			shader_set_i("sampleMode",	_samp);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[6], _data[7]);
		_outSurf = channel_apply(_surf, _outSurf, _data[9]);
		
		return _outSurf;
	}
}