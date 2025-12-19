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
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { }
	
	static step = function() {}
	
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
		
		return _outData; 
	}
}