function Node_Weld(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Weld";
	
	newActiveInput( 3 );
	newInput( 4, nodeValue_Toggle( "Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface 1"  ));
	newInput( 1, nodeValue_Surface( "Surface 2"  ));
	newInput( 7, nodeValue_Surface( "Mask"       ));
	newInput( 2, nodeValue_Slider(  "Mix",     1 ));
	__init_mask_modifier(7, 5); // inputs 5, 6, 
	
	////- =Weld
	newInput( 8, nodeValue_Float(  "Radius",  8 )).setMappable(9).setUnitSimple(false);
	newInput(10, nodeValue_Float(  "Factor",  2 ));
	// input 10
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 3, 4, 
		[ "Surfaces", false ],  0,  1,  7,  2,  5,  6, 
		[ "Weld",     false ],  8,  9, 10, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { }
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _surf1 = _data[ 0];
			var _surf2 = _data[ 1];
			
			var _rad   = _data[ 8];
			var _fac   = _data[10];
			
			if(!is_surface(_surf1)) return _outSurf;
		#endregion
		
		var _dim = surface_get_dimension(_surf1);
		
		surface_set_shader(_outSurf, sh_weld);
			shader_set_s("surface1",   _surf1 );
			shader_set_s("surface2",   _surf2 );
			shader_set_2("dimension",  _dim   );
			
			shader_set_f_map("radius", _rad, _data[9], inputs[8] );
			shader_set_f("factor",     _fac   );
			
			draw_empty();
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf1, _outSurf, _data[7], _data[2]);
		_outSurf = channel_apply(_surf1, _outSurf, _data[4]);
		
		return _outSurf; 
	}
}