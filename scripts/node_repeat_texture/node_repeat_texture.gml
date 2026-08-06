#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Repeat_Texture", "Type > Toggle", "T", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue((_n.inputs[2].getValue() + 1) % 3); });
	});
#endregion

function Node_Repeat_Texture(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Repeat Texture";
	dimension_index = 1;
	
	newInput( 3, nodeValueSeed());
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" )).setRequired();
	
	////- =Repeat
	newInput( 1, nodeValue_Dimension( "Target Dimension" ));
	newInput( 2, nodeValue_EScroll(   "Type",        1, [ "Tile", "Scatter", "Cell" ] ));
	newInput( 4, nodeValue_Slider(    "Randomness",  1 ));
	// 5
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 3, 
		[ "Surfaces", false ],  0, 
		[ "Repeat",   false ],  1,  2,  4, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
		
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _seed = _data[ 3];
			
			var _surf = _data[ 0];
			
			var _dim  = _data[ 1];
			var _type = _data[ 2];
			var _rand = _data[ 4];
			
			inputs[4].setVisible(_type != 0);
		#endregion
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		if(!is_surface(_surf)) return _outSurf;
		
		var _sdim = surface_get_dimension(_surf);
		
		gpu_set_texrepeat(1);
		surface_set_shader(_outSurf, sh_texture_repeat);
			shader_set_f( "seed",       _seed );
			
			shader_set_f( "dimension",  _dim  );
			shader_set_f( "sDimension", _sdim );
			
			shader_set_s( "surface",    _surf );
			shader_set_i( "type",       _type );
			shader_set_f( "randomness", _rand );
			
			draw_empty();
		surface_reset_shader();
		gpu_set_texrepeat(0);
		
		return _outSurf;
	}
}