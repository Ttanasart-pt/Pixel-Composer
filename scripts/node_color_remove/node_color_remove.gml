#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Color_Remove", "Invert > Toggle",  "I", MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS _n.inputs[6].setValue(!_n.inputs[6].getValue()); });
	});
#endregion

function Node_Color_Remove(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Remove Color";
	
	newActiveInput(5);
	newInput(7, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(3, nodeValue_Surface( "Mask"       ));
	newInput(4, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(3, 8); // inputs 8, 9, 
	
	////- =Remove
	newInput(11, nodeValue_EButton( "Color Space", 0, [ "RGB", "LAB" ] ));
	newInput( 1, nodeValue_Palette( "Colors",    [ ca_black ] ));
	newInput( 2, nodeValue_Slider(  "Threshold", .1 )).setMappable(10);
	newInput( 6, nodeValue_Bool(    "Invert",    false, "Keep the selected colors and remove the rest."));
	// input 12
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [  5,  7, 
		[ "Surfaces",  true ],  0,  3,  4,  8,  9, 
		[ "Remove",   false ], 11,  1,  2, 10,  6, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _surf = _data[ 0];
			
			var _spac = _data[11];
			var _colr = _data[ 1];
			var _thrs = _data[ 2];
			var _invt = _data[ 6];
		#endregion
		
		var _colors = [];
		for(var i = 0; i < array_length(_colr); i++)
			array_append(_colors, colToVec4(_colr[i]));
		
		surface_set_shader(_outSurf, sh_color_remove);
			shader_set_i("colorSpace",    _spac   );
			shader_set_f("colorFrom",     _colors );
			shader_set_i("colorFrom_amo", array_length(_colr));
			
			shader_set_f_map("treshold",  _thrs, _data[10], inputs[2]);
			shader_set_i("invert",        _invt );
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_surf, _outSurf, _data[7]);
		
		return _outSurf;
	}
}