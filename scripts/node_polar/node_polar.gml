#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Polar", "Radius Mode > Toggle", "R", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[9].setValue((_n.inputs[9].getValue() + 1) % 3); });
	});
#endregion

function Node_Polar(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Polar";
	
	newActiveInput(3);
	newInput(4, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput( 1, nodeValue_Surface( "Mask"       ));
	newInput( 2, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(1, 7); // inputs 7, 8, 
	newInput(12, nodeValue_Vec2("Tile", [ 1, 1 ] ));
	
	////- =Polar
	newInput(16, nodeValue_Rotation(    "Angle",        0 )).setMappable(17);
	newInput( 5, nodeValue_Bool(        "Invert",       0 ))
	newInput(10, nodeValue_Bool(        "Swap Axis",    0 ));
	newInput( 6, nodeValue_Slider(      "Blend",        1 )).setMappable(11);
	newInput( 9, nodeValue_Enum_Scroll( "Radius Mode",  0, [ new scrollItem("Linear",         s_node_curve_type, 2), 
                                                             new scrollItem("Inverse Square", s_node_curve_type, 1), 
                                                             new scrollItem("Logarithm",      s_node_curve_type, 3), ]));
	newInput(13, nodeValue_RotRange(   "Range", [0,360] ));
	
	////- =Twist
	newInput(14, nodeValue_Float( "Twist", 0 )).setMappable(15);
	// input 18
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 3, 4,
		[ "Surfaces", false ],  0,  1,  2,  7,  8, 12, 
		[ "Polar",    false ], 16, 17,  5, 10,  6, 11,  9, 13, 
		[ "Twist",    false ], 14, 15, 
	];
	
	////- Node
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _surf = _data[ 0];
			var _tile = _data[12];
			
			var _angl = _data[16];
			var _invt = _data[ 5];
			var _swap = _data[10];
			var _blnd = _data[ 6];
			var _radd = _data[ 9];
			var _rang = _data[13];
			
			var _twst = _data[14];
		#endregion
		
		surface_set_shader(_outSurf, sh_polar);
			shader_set_interpolation( _surf );
			shader_set_2("tile",      _tile );
			
			shader_set_i("invert",    _invt );
			shader_set_i("swap",      _swap );
			shader_set_f_map("angle", _angl, _data[17], inputs[16]);
			shader_set_f_map("blend", _blnd, _data[11], inputs[ 6]);
			shader_set_i("distMode",  _radd );
			shader_set_2("range",     _rang );
			
			shader_set_f_map("twist", _twst, _data[15], inputs[14]);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[1], _data[2]);
		_outSurf = channel_apply(_surf, _outSurf, _data[4]);
		
		return _outSurf;
	}
}