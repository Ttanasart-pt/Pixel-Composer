function Node_Normal_to_Direction(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Normal to Direction";
	
	////- =Normal
	newInput( 0, nodeValue_Surface( "Normal" )).setRequired();
	newInput( 4, nodeValue_Float(   "Smooth",    0     ));
	
	////- =Direction
	newInput( 1, nodeValue_Rotation( "Offset",   0     ));
	newInput( 3, nodeValue_Float(    "Scale",    1     ));
	newInput( 2, nodeValue_Bool(     "Inverted", false ));
	// 5
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Normal",    false ],  0,  4, 
		[ "Direction", false ],  1,  3,  2, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _surf = _data[ 0];
			var _smth = _data[ 4];
			
			var _soff = _data[ 1];
			var _sca  = _data[ 3];
			var _inv  = _data[ 2];
			
			if(!is_surface(_surf)) return _outSurf;
		#endregion
		
		var _dim = surface_get_dimension(_surf);
		
		surface_set_shader(_outSurf, sh_normal_to_direction);
			shader_set_2( "dimension", _dim  );
			shader_set_f( "smooth",    _smth );
			
			shader_set_f( "direction", _soff );
			shader_set_f( "scale",     _sca  );
			shader_set_i( "inverted",  _inv  );
			
			draw_surface(_surf, 0, 0);
		surface_reset_shader();
		
		return _outSurf; 
	}
}