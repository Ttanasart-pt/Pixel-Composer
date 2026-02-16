function Node_Point_SDF(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Point to SDF";
	dimension_index = 0;
	
	newInput(0, nodeValue_Dimension());
	
	////- =Points
	newInput(1, nodeValue_Vec2( "Points", [] )).setVisible(true, true).setArrayDepth(1);
	
	////- =Render
	newInput(2, nodeValue_Float( "Max Distance", 16    ));
	newInput(3, nodeValue_Bool(  "Inverted",     false ));
	// inputs 4
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		[ "Points", false ], 1, 
		[ "Render", false ], 2, 3, 
	]
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim  = _data[0];
		
		var _points = _data[1];
		var _maxd   = _data[2];
		var _inv    = _data[3];
		
		var _amo = array_length(_points);
		if(_amo <= 0) return _outSurf;
		
		var _p = array_create(_amo * 2);
		for( var i = 0; i < _amo; i++ ) {
			_p[i * 2 + 0] = _points[i][0];
			_p[i * 2 + 1] = _points[i][1];
		}
		
		surface_set_shader(_outSurf, sh_point_sdf);
			shader_set_2("dimension",   _dim);
			shader_set_i("pointAmount", _amo);
			shader_set_f("points",      _p);
			shader_set_f("maxDistance", _maxd);
			shader_set_i("inverted",    _inv);
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf;
	}
} 