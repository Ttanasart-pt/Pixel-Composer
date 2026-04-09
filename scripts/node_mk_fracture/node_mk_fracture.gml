function Node_MK_Fracture(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Fracture";
	
	newInput( 0, nodeValue_Surface("Surface In"));
	
	////- =Fracture
	newInput( 1, nodeValue_Vec2(        "Subdivision", [4,4] ));
	newInput( 2, nodeValue_Slider(      "Progress",    .5 )).setMappable(3);
	newInput(13, nodeValue_Enum_Button( "Brick Axis",   0, [ "X", "Y" ] ));
	newInput(11, nodeValue_Slider(      "Brick Shift",  0 ));
	newInput(12, nodeValue_Slider(      "Skew",         0, [ -1, 1, 0.01 ] ));
	
	////- =Physics
	newInput( 4, nodeValue_Vec2(     "Movement",  [0,0] )).setMappable(9, true);
	newInput( 5, nodeValue_Rotation( "Rotation",   180  )).setMappable(10);
	newInput( 6, nodeValue_Slider(   "Scale",      0    ));
	newInput( 8, nodeValue_Float(    "Gravity",    0    ));
	
	////- =Render
	newInput( 7, nodeValue_Slider( "Alpha", 1 ));
	// input 14
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 0, 
		[ "Fracture", false ],  1,  2, 13, 11, 12, 
		[ "Physics",  false ],  3,  4,  9,  8,  5, 10,  6, 
		[ "Render",   false ],  7, 
	];
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _surf = _data[ 0];
			
			var _subd = _data[ 1];
			var _prog = _data[ 2];
			var _axis = _data[13];
			var _shft = _data[11];
			var _skew = _data[12];
			
			var _move = _data[ 4];
			var _rota = _data[ 5];
			var _scal = _data[ 6];
			var _grav = _data[ 8];
			
			var _alph = _data[ 7];
			
			if(!is_surface(_surf)) return _outSurf;
		#endregion
			
		var _dim  = surface_get_dimension(_surf);
		
		surface_set_shader(_outSurf, sh_mk_fracture);
			shader_set_f("dimension",    _dim  );
			
			shader_set_f( "subdivision",  _subd );
			shader_set_f_map( "progress", _prog, _data[ 3], inputs[ 2]);
			shader_set_i( "axis",		  _axis );
			shader_set_f( "brickShift",   _shft );
			shader_set_f( "skew",         _skew );
			
			shader_set_f_map( "movement", _move, _data[ 9], inputs[ 4]);
			shader_set_f_map( "rotation", _rota, _data[10], inputs[ 5]);
			shader_set_f( "scale",        _scal );
			shader_set_f( "gravity",      _grav );
			
			shader_set_f( "alpha",        _alph );
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		return _outSurf;
	}
}