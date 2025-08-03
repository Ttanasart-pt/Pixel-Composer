function Node_Transform_Iso(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Transform Iso";
	
	newInput(0, nodeValue_Surface( "Surface In" ));
	
	////- =Isometric
	
	newInput(1, nodeValue_Enum_Button( "Side", [ "Top", "Left", "Right" ] ));
	
	// input 2
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0,
		["Isometric", false], 1, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { }
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		var _surf = _data[0];
		var _side = _data[1];
		
		var _dim  = surface_get_dimension(_surf);
		var _sdim = [
			_dim[0] * 1,
			_dim[1] * 2,
		];
		
		_outSurf = surface_verify(_outSurf, _sdim[0], _sdim[1]);
		surface_set_shader(_outSurf, sh_transform_iso_top);
			shader_set_surface("baseSurface", _surf);
			
			shader_set_2( "baseDimension", _dim  );
			shader_set_2( "dimension",     _sdim );
			
			draw_empty();
		surface_reset_shader();
		
		
		return _outSurf; 
	}
}