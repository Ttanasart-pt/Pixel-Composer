function Node_Average(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Average";
	
	newActiveInput(3);
	newInput(4, nodeValue_Toggle( "Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(1, nodeValue_Surface( "Mask"       ));
	newInput(2, nodeValue_Slider(  "Mix",     1 ));
	__init_mask_modifier(1, 5); // inputs 5, 6, 
	// input 7
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface,  noone ));
	newOutput(1, nodeValue_Output( "Color",       VALUE_TYPE.color, ca_black ));
	
	input_display_list = [ 3, 4, 
		["Surfaces", false], 0, 1, 2, 5, 6, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	temp_surface = [0,0]
	
	static processData = function(_outData, _data, _array_index) {
		var inSurf   = _data[0];
		var _outSurf = _outData[0];
		
		if(!is_surface(inSurf)) return [ _outSurf, c_black ];
		
		var lop  = ceil(log2(max(surface_get_width_safe(inSurf), surface_get_height_safe(inSurf))));
		var side = power(2, lop);
		var cc;
		
		if(side / 2 >= 1) {
			temp_surface[0] = surface_verify(temp_surface[0], side, side);
			temp_surface[1] = surface_verify(temp_surface[1], side, side);
			var _ind = 1;
			
			surface_set_shader(temp_surface[0], noone);
				draw_surface_stretched_safe(inSurf, 0, 0, side, side);
			surface_reset_shader();
			
			for( var i = 0; i <= lop; i++ ) {
				surface_set_shader(temp_surface[_ind], sh_average);
					shader_set_f("dimension", side);
					draw_surface_safe(temp_surface[!_ind]);
				surface_reset_shader();
				
				_ind = !_ind;
				side /= 2;
			}
			
			cc = surface_get_pixel_ext(temp_surface[!_ind], 0, 0);
			
		} else 
			cc = surface_get_pixel_ext(inSurf, 0, 0);
		
		surface_set_target(_outSurf);
			draw_clear(cc);
		surface_reset_target();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[1], _data[2]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[4]);
		
		return [ _outSurf, cc ];
	}
}