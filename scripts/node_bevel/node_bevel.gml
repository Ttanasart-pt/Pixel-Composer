function Node_Bevel(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Bevel";
	
	newActiveInput(7);
	
	////- =Surfaces
	newInput( 8, nodeValue_Enum_Scroll("Oversample mode", 0, [ "Empty", "Clamp", "Repeat" ]));
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput( 5, nodeValue_Surface( "Mask"       ));
	newInput( 6, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(5, 9); // inputs 9, 10
	
	////- =Bevel
	newInput( 4, nodeValue_Enum_Scroll( "Slope", 0, [ new scrollItem("Linear",   s_node_curve_type, 2), 
                                                      new scrollItem("Smooth",   s_node_curve_type, 4), 
                                                      new scrollItem("Circular", s_node_curve_type, 5), ]));
	newInput( 1, nodeValue_Int(  "Height",  4     )).setMappable(11);
	newInput(12, nodeValue_Bool( "Highres", false ));
	
	////- =Transform
	newInput( 2, nodeValue_Vec2( "Shift", [ 0, 0 ] )).setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	newInput( 3, nodeValue_Vec2( "Scale", [ 1, 1 ] ));
	
	// input 13
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 7, 
		["Surfaces",	 true], 0, 5, 6, 9, 10, 
		["Bevel",		false], 4, 1, 11, 12, 
		["Transform",	false], 2, 3, 
	];
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _surf = current_data[0];
		if(!is_surface(_surf)) return false;
		
		var _pw = surface_get_width_safe(_surf) * _s / 2;
		var _ph = surface_get_height_safe(_surf) * _s / 2;
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x + _pw, _y + _ph, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _hei = _data[ 1];
		var _shf = _data[ 2];
		var _sca = _data[ 3];
		var _slp = _data[ 4];
		var _dim = surface_get_dimension(_data[0]);
		var _hig = _data[12];
		
		surface_set_shader(_outSurf, _hig? sh_bevel_highp : sh_bevel);
			shader_set_f("dimension",  _dim);
			shader_set_f_map("height", _hei, _data[11], inputs[1]);
			shader_set_2("shift",      _shf);
			shader_set_2("scale",      _sca);
			shader_set_i("slope",      _slp);
			shader_set_i("sampleMode", getAttribute("oversample"));
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[5], _data[6]);
		
		return _outSurf;
	}
}