function Node_VerletSim_Mesh_Cache_Lerp(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Mesh Mix Cache";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Mesh(   "Mesh"       )).setVisible(true, true);
	newInput(1, nodeValue_Struct( "Cache Mesh" )).setVisible(true, true);
	newInput(2, nodeValue_Slider( "Amount", .5 ));
	// input 3
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone));
	
	input_display_list = [ 0, 1, 2  ];
	
	attributes.cache_data = undefined;
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		
	}
	
	static update = function() {
		var _mesh = getInputData(0);
		outputs[0].setValue(_mesh);
		
		if(!is(_mesh, __verlet_Mesh)) return;
		
		var _cach = getInputData(1);
		if(!is_struct(_cach) || !struct_has(_cach, "points")) return;
		
		var _lerp = getInputData(2);
		
		var _mp  = _mesh.points;
		var _cp  = _cach.points;
		var _amo = min(array_length(_mp), array_length(_cp));
		
		for( var i = 0; i < _amo; i++ ) {
			_mp[i].dx = lerp(_mp[i].x, _cp[i][0], _lerp);
			_mp[i].dy = lerp(_mp[i].y, _cp[i][1], _lerp);
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_verletsim_mesh_cache_lerp, 0, bbox);
	}
	
}
