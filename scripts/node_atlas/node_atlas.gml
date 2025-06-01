function Node_Atlas(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Pixel Expand";
	
	newActiveInput(1);
	newInput(0, nodeValue_Surface("Surface In"));
	newInput(2, nodeValue_Enum_Scroll("Method", 0, [ "Radial", "Scan" ]));
	
	// input 3
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 0, 2 ];
	
	temp_surface = array_create(2);
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		var _meth = _data[2];
		var _dim  = surface_get_dimension(_data[0]);
		
		for( var i = 0; i < 2; i++ ) temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
		
		if(_meth == 0) {
			var _bg  = 0;
			var _itr = ceil(max(_dim[0], _dim[1]) / 16);
		
			surface_set_shader(temp_surface[!_bg]);
				draw_surface_safe(_surf);
			surface_reset_shader();
		
			repeat(_itr) {
				surface_set_shader(temp_surface[_bg], sh_atlas);
					shader_set_f("dimension", _dim);
					draw_surface_safe(temp_surface[!_bg]);
				surface_reset_shader();
			
				_bg = !_bg;
			}
			
			surface_set_shader(_outSurf);
				draw_surface_safe(temp_surface[!_bg]);
			surface_reset_shader();
			
		} else if(_meth == 1) {
			
			surface_set_shader(temp_surface[0], sh_atlas_scan);
				shader_set_f("dimension", _dim);
				shader_set_f("iteration", _dim[0]);
				shader_set_i("axis", 0);
				
				draw_surface_safe(_surf);
			surface_reset_shader();
			
			surface_set_shader(temp_surface[1], sh_atlas_scan);
				shader_set_f("dimension", _dim);
				shader_set_f("iteration", _dim[1]);
				shader_set_i("axis", 1);
				
				draw_surface_safe(temp_surface[0]);
			surface_reset_shader();
			
			surface_set_shader(_outSurf);
				draw_surface_safe(temp_surface[1]);
			surface_reset_shader();
		}
		
		return _outSurf;
	}
}