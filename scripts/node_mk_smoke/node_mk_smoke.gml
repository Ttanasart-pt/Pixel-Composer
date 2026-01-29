function Node_MK_Smoke(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Smoke";
	
	////- =Output
	newInput(0, nodeValue_Dimension());
	
	////- =Spawn
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 
		[ "Output", false ], 0, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { }
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _dim = _data[0];
		#endregion
		
		surface_set_shader(_outSurf);
			
			
		surface_reset_shader();
		
		return _outSurf; 
	}
}