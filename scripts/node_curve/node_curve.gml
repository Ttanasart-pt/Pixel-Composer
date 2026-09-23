function Node_Curve(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Curve";
	
	newActiveInput(7);
	newInput(8, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" )).setRequired();
	newInput(5, nodeValue_Surface( "Mask"       ));
	newInput(6, nodeValue_Slider(  "Mix",     1 ));
	__init_mask_modifier(5, 9); // inputs 9, 10
	
	////- =Dynamic Range
	newInput(12, nodeValue_Range( "Range In",  [0,1] ));
	newInput(13, nodeValue_Range( "Range Out", [0,1] ));
	
	////- =Curves
	newInput( 1, nodeValue_Curve( "Brightness", CURVE_DEF_01 ));
	newInput( 2, nodeValue_Curve( "Red",        CURVE_DEF_01 ));
	newInput( 3, nodeValue_Curve( "Green",      CURVE_DEF_01 ));
	newInput( 4, nodeValue_Curve( "Blue",       CURVE_DEF_01 ));
	newInput(11, nodeValue_Curve( "Alpha",      CURVE_DEF_01 ));
	// input 14
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [  7,  8, 
		[ "Surfaces",       true ],  0,  5,  6,  9, 10, 
		[ "Dynamic Range", false ], 12, 13, 
		[ "Curves",        false ],  1,  2,  3,  4, 11, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {	
		#region data
			var _bin  = _data[12];
			var _bout = _data[13];
			
			var _wcur = _data[ 1];
			var _rcur = _data[ 2];
			var _gcur = _data[ 3];
			var _bcur = _data[ 4];
			var _acur = _data[11];
		#endregion
		
		surface_set_shader(_outSurf, sh_curve);
			shader_set_2( "bIn",  _bin  );
			shader_set_2( "bOut", _bout );
			
			shader_set_cr( "w", _wcur );
			shader_set_cr( "r", _rcur );
			shader_set_cr( "g", _gcur );
			shader_set_cr( "b", _bcur );
			shader_set_cr( "a", _acur );
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply_input(_data[0], _outSurf, _data[5], _data[6], inputs[5]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[8]);
		
		return _outSurf;
	}
}
