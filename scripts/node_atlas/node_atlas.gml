function Node_Atlas(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Pixel Expand";
	
	newActiveInput(1);
	newInput( 4, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surface
	newInput( 0, nodeValue_Surface("Surface In"));
	newInput( 5, nodeValue_Surface( "Mask"       ));
	newInput( 6, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(5, 7); // inputs 7, 8
	
	////- =Expands
	newInput( 2, nodeValue_EScroll( "Method",     0, [ "Radial", "Scan" ]));
	newInput( 3, nodeValue_Int(     "Resolution", 32 ));
	// 5
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 4, 
		[ "Surface", false ],  0,  5,  6,  7,  8, 
		[ "Expands", false ],  2,  3, 
	];
	
	////- Node
	
	temp_surface = array_create(2);
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _surf = _data[ 0];
			
			var _meth = _data[ 2];
			var _reso = _data[ 3];
			
			if(!is_surface(_surf)) return _outSurf;
		#endregion
		
		var _dim = surface_get_dimension(_surf);
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1]);
		temp_surface[1] = surface_verify(temp_surface[1], _dim[0], _dim[1]);
		
		if(_meth == 0) {
			var _bg  = 0;
			var _itr = ceil(max(_dim[0], _dim[1]) / 16);
		
			surface_set_shader(temp_surface[!_bg]);
				draw_surface_safe(_surf);
			surface_reset_shader();
		
			repeat(_itr) {
				surface_set_shader(temp_surface[_bg], sh_atlas);
					shader_set_f("dimension",   _dim  );
					shader_set_f("resolution",  _reso );
					
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
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply_input(_surf, _outSurf, _data[5], _data[6], inputs[5]);
		_outSurf = channel_apply(_surf, _outSurf, _data[4]);
		
		return _outSurf;
	}
}