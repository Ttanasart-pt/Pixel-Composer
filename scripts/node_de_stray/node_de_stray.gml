function Node_De_Stray(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "De-Stray";
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	newInput(1, nodeValue_Slider("Tolerance", 0));
	
	newActiveInput(2);
	
	newInput(3, nodeValue_Int("Iteration", 2))
	
	newInput(4, nodeValue_Enum_Button("Strictness",  0, [ "Low", "High", "Stray-only" ]));
	
	newInput(5, nodeValue_Surface("Mask"));
	
	newInput(6, nodeValue_Slider("Mix", 1));
	
	__init_mask_modifier(5, 7); // inputs 7, 8, 
	
	newInput(9, nodeValue_Bool("Fill Empty", false));
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 2, 
		["Surfaces",  true], 0, 5, 6, 7, 8, 
		["Effect",	 false], 4, 1, 3, 9, 
	]
	
	attribute_surface_depth();
	
	temp_surface = [ noone, noone ];
	
	static processData = function(_outSurf, _data, _array_index) {
		var surf = _data[0];
		var _tol = _data[1];
		var _itr = _data[3];
		var _str = _data[4];
		var _fil = _data[9];
		
		var _sw  = surface_get_width_safe(surf);
		var _sh  = surface_get_height_safe(surf);
		
		for( var i = 0; i < 2; i++ ) temp_surface[i] = surface_verify(temp_surface[i], _sw, _sh);
		
		var _bg = 0;
		surface_set_shader(temp_surface[1]);
			draw_surface_safe(surf);
		surface_reset_shader();
		
		repeat(_itr) {
			surface_set_shader(temp_surface[_bg], sh_de_stray);
				shader_set_f("dimension", _sw, _sh);
				shader_set_f("tolerance", _tol);
				shader_set_i("strict",    _str);
				shader_set_i("fill",      _fil);
			
				draw_surface_safe(temp_surface[!_bg]);
			surface_reset_shader();
		
			_bg = !_bg;
		}
		
		surface_set_shader(_outSurf);
			draw_surface_safe(temp_surface[!_bg]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[5], _data[6]);
		
		return _outSurf;
	}
}