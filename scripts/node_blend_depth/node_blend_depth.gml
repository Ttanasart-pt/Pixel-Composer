function Node_Blend_Depth(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Blend Depth";
	
	newInput(0, nodeValue_Surface( "Surface 1" )).setDrawGroup(0);
	newInput(1, nodeValue_Surface( "Depth 1"   )).setDrawGroup(0);
	newInput(4, nodeValue_Range(   "Depth Range 1", [0,1] )).setDrawGroup(0);
	
	newInput(2, nodeValue_Surface( "Surface 2" )).setDrawGroup(1);
	newInput(3, nodeValue_Surface( "Depth 2"   )).setDrawGroup(1);
	newInput(5, nodeValue_Range(   "Depth Range 2", [0,1] )).setDrawGroup(1);
	// input 6
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone)).setDrawGroup(2);
	newOutput(1, nodeValue_Output("Depth Out",   VALUE_TYPE.surface, noone)).setDrawGroup(2);
	
	input_display_list = [ 
		[ "Surface 1", false ], 0, 1, 4, 
		[ "Surface 2", false ], 2, 3, 5, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { }
	
	static step = function() {}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		var _surf1 = _data[0];
		var _dept1 = _data[1];
		var _rang1 = _data[4];
		
		var _surf2 = _data[2];
		var _dept2 = _data[3];
		var _rang2 = _data[5];
		
		surface_set_shader(_outData, sh_blend_depth);
			shader_set_s( "surface_1", _surf1 );
			shader_set_s( "depth_1",   _dept1 );
			shader_set_2( "range_1",   _rang1 );
			
			shader_set_s( "surface_2", _surf2 );
			shader_set_s( "depth_2",   _dept2 );
			shader_set_2( "range_2",   _rang2 );
			
			draw_empty();
		surface_reset_shader();
		
		return _outData; 
	}
}