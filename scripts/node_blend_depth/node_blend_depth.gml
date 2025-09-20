function Node_Blend_Depth(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Blend Depth";
	
	newInput(0, nodeValue_Surface( "Surface 1" ));
	newInput(1, nodeValue_Surface( "Depth 1"   ));
	newInput(2, nodeValue_Surface( "Surface 2" ));
	newInput(3, nodeValue_Surface( "Depth 2"   ));
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Surfaces", false ], 0, 1, 2, 3, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { }
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		var _surf1 = _data[0];
		var _dept1 = _data[1];
		var _surf2 = _data[2];
		var _dept2 = _data[3];
		
		surface_set_shader(_outSurf, sh_blend_depth);
			shader_set_s( "surface_1", _surf1 );
			shader_set_s( "depth_1",   _dept1 );
			shader_set_s( "surface_2", _surf2 );
			shader_set_s( "depth_2",   _dept2 );
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf; 
	}
}