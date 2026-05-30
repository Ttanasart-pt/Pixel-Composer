function Node_Point_SDF(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Point to SDF";
	dimension_index = 0;
	
	newInput( 0, nodeValue_Dimension());
	
	////- =Points
	newInput( 1, nodeValue_Vec2( "Points", [] )).setVisible(true, true).setArrayDepth(1);
	
	////- =Render
	newInput( 2, nodeValue_Float( "Max Distance", 16    )).setMappable( 4);
	newInput( 3, nodeValue_Bool(  "Inverted",     false ));
	// inputs 5
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [  0, 
		[ "Points", false ],  1, 
		[ "Render", false ],  2,  4,  3, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _dim    = _data[ 0];
			
			var _points = _data[ 1];
			var _maxd   = _data[ 2];
			var _inv    = _data[ 3];
		#endregion
		
		var _amo = array_length(_points);
		if(_amo <= 0) return _outSurf;
		
		var _p = array_create(_amo * 2);
		for( var i = 0; i < _amo; i++ ) {
			_p[i * 2 + 0] = _points[i][0];
			_p[i * 2 + 1] = _points[i][1];
		}
		
		surface_set_shader(_outSurf, sh_point_sdf);
			shader_set_2( "dimension",   _dim  );
			shader_set_i( "pointAmount", _amo  );
			shader_set_f( "points",      _p    );
			shader_set_m( "maxDistance", _maxd, _data[ 4], inputs[ 2] ); 
			shader_set_i( "inverted",    _inv  );
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf;
	}
} 