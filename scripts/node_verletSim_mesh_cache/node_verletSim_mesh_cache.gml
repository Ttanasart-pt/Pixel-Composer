function Node_VerletSim_Mesh_Cache(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Cache Mesh";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	update_on_frame = true;
	setDrawIcon(s_node_verletsim_mesh_cache);
	setDimension(96, 48);
	
	newInput(0, nodeValue_Mesh( "Mesh" )).setVisible(true, true);
	
	newInput(1, nodeValue_Bool( "Autocache", false ));
	newInput(2, nodeValue_Int(  "Frame",     1     ));
	
	newOutput(0, nodeValue_Output("Cached Data", VALUE_TYPE.struct, noone));
	
	input_display_list = [ 0, button(function() /*=>*/ {return cacheMesh()}).setText("Cache"),
		["Auto Cache", false, 1], 2, 
	];
	
	attributes.cache_data = undefined;
	
	////- Nodes
	
	static cacheMesh = function() {
		var _mesh = getInputData(0);
		if(!is(_mesh, __verlet_Mesh)) return;
		
		var p = _mesh.points;
		var a = array_length(p);
		
		var _p = array_create(a);
		for( var i = 0; i < a; i++ ) {
			_p[i] = [ p[i].x, p[i].y ];
		}
		
		attributes.cache_data = {
			points: _p,
		}
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _msh = getInputData(0);
		
		if(is(_msh, Mesh)) {
			draw_set_color(COLORS._main_icon);
			_msh.draw(_x, _y, _s);
		}
		
		return w_hovering;
	}
	
	static update = function() {
		var _auto_cache = getInputData(1);
		var _auto_frame = getInputData(2);
		
		if(_auto_cache && CURRENT_FRAME == _auto_frame)
			cacheMesh();
		
		outputs[0].setValue(attributes.cache_data);
	}
	
}
