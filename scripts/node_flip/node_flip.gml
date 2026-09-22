#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Flip", "Axis > Toggle", "A", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[1].setValue((_n.inputs[1].getValue() + 1) % 2); });
	});
#endregion

function Node_Flip(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Flip";
	
	newActiveInput(2);
	newInput( 3, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" )).setRequired();
	newInput( 4, nodeValue_Surface( "Mask"       ));
	newInput( 5, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(4, 6); // inputs 6, 7 
	
	////- =Flip
	newInput( 1, nodeValue_Toggle(  "Axis",  1, [ "X", "Y" ] )).setPieMenu();
	// 8
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
		
	input_display_list = [  2,  3, 
		[ "Surfaces", false ],  0,  4,  5,  6,  7, 
		[ "Flip",     false ],  1,
	];
	
	////- Node
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _surf = _data[ 0];
			
			var _axis = _data[ 1];
			
			if(!is_surface(_surf)) return _outSurf;
		#endregion
		
		surface_set_shader(_outSurf, sh_flip);
			shader_set_i("axis", _axis);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply_input(_surf, _outSurf, _data[4], _data[5], inputs[4]);
		_outSurf = channel_apply(_surf, _outSurf, _data[3]);
		
		return _outSurf;
	}
}