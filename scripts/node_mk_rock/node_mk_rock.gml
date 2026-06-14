function Node_MK_Rock(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Rock";
	
	newInput( 2, nodeValueSeed());
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput( 1, nodeValue_Surface( "Background" ));
	// 3
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ s_MKFX, 2, 
		[ "Output",    false ],  0,  1, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { }
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _seed   = _data[ 2];
			
			var _dim    = _data[ 0];
			var _bgSurf = _data[ 1];
		#endregion
		
		surface_set_shader(_outSurf, sh_mk_rock);
			
		surface_reset_shader();
		
		return _outSurf;
	}
}