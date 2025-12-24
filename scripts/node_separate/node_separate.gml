function Node_Separate(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Separate";
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In"    ));
	newInput(1, nodeValue_Surface( "Separate Mask" ));
	
	////- =Separation
	newInput(2, nodeValue_Slider( "Threshold", .5 ));
	
	newOutput(0, nodeValue_Output( "Surface 0", VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output( "Surface 1", VALUE_TYPE.surface, noone ));
	
	input_display_list = [ 
		[ "Surfaces",   false ], 0, 1, 
		[ "Separation", false ], 2, 
	];
	
	////- Nodes
	
	preview_size = 256;
	temp_surface = [ noone, noone, noone, noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _mask = getInputSingle(1);
		var _thr  = getInputSingle(2);
		
		var _panl = _params.panel;
		var _pw   = _params.w;
		var _ph   = _params.h;
		
		if(is_surface(_mask)) {
			temp_surface[0] = surface_verify(temp_surface[0], _pw, _ph);
			temp_surface[1] = surface_verify(temp_surface[1], _pw, _ph);
			
			surface_set_shader(temp_surface[0]);
				draw_surface_ext(_mask, _x, _y, _s, _s, 0, c_white, 1);
			surface_reset_shader();
			
			surface_set_shader(temp_surface[1], sh_separate_preview_outline);
				shader_set_2( "dimension", [_pw,_ph] );
				shader_set_f( "threshold",  _thr     );
				
				draw_surface_ext(temp_surface[0], 0, 0, 1, 1, 0, COLORS._main_accent, 1);
			surface_reset_shader();
			
			draw_surface(temp_surface[1], 0, 0);
		}
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _surf = _data[0];
			var _mask = _data[1];
			var _thr  = _data[2];
		#endregion
		
		surface_set_shader(_outData, sh_separate);
			shader_set_s( "mask",      _mask );
			shader_set_f( "threshold", _thr  );
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		#region preview
			var _dim = surface_get_dimension(_mask);
			
			temp_surface[2] = surface_verify(temp_surface[0], preview_size, preview_size);
			temp_surface[3] = surface_verify(temp_surface[1], preview_size, preview_size);
			var ss = min(preview_size / _dim[0], preview_size / _dim[1]);
			
			surface_set_shader(temp_surface[2]);
				draw_surface_ext(_mask, preview_size/2 - _dim[0]*ss/2, preview_size/2 - _dim[1]*ss/2, ss, ss, 0, c_white, 1);
			surface_reset_shader();
			
			surface_set_shader(temp_surface[3], sh_separate_preview_outline);
				shader_set_2( "dimension", [ preview_size, preview_size ] );
				shader_set_f( "threshold",  _thr     );
				
				draw_surface_ext(temp_surface[2], 0, 0, 1, 1, 0, COLORS._main_accent, 1);
			surface_reset_shader();
		#endregion
		
		return _outData; 
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		
		draw_surface_bbox(temp_surface[3], bbox);
	}
}