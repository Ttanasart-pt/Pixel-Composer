function Node_VerletSim_Mesh(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Verlet Mesh";
	setDimension(96, 48);
	
	////- =Mesh
	newInput(0, nodeValue_Mesh(   "Mesh" )).setVisible(true, true);
	newInput(1, nodeValue_Slider( "Tension",  .5 ));
	
	////- =Mesh
	newInput(2, nodeValue_Bool( "Remap",  false  ));
	newInput(3, nodeValue_Area( "UV Map", DEF_AREA_REF, { useShape : false } )).setUnitRef(function(i) /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	
	// input 4
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone));
	
	input_display_list = [ 
		[ "Mesh",   false ], 0, 1,
		[ "Map UV", false, 2 ], 3, 
	];
	
	////- Nodes
	
	mesh = noone;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _msh = getInputData(0);
		var _uv  = getInputData(2);
		
		if(is(_msh, Mesh)) {
			draw_set_color(COLORS._main_icon);
			_msh.draw(_x, _y, _s);
		}
		
		if(_uv) InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		return w_hovering;
	}
	
	static update = function() {
		if(!IS_FIRST_FRAME) return;
		
		var _msh = getInputData(0);
		var _ten = getInputData(1); __tens = 1 - _ten;
		
		var _uv  = getInputData(2);
		var _uva = getInputData(3);
		mesh = noone;
		
		var x0 = _uva[0] - _uva[2]; 
		var y0 = _uva[1] - _uva[3];
		var ww = _uva[2] * 2;
		var hh = _uva[3] * 2;
		
		if(is(_msh, Mesh)) {
			mesh = new __verlet_Mesh();
			mesh.edges     = array_clone(_msh.edges);
			mesh.triangles = array_clone(_msh.triangles);
			
			mesh.center    = array_clone(_msh.center);
			mesh.bbox      = array_clone(_msh.bbox);
			
			for( var i = 0, n = array_length(_msh.points); i < n; i++ ) {
				mesh.points[i] = new __verlet_vec2().set2(_msh.points[i]);
				
				if(_uv) {
					mesh.points[i].u = (mesh.points[i].x - x0) / ww;
					mesh.points[i].v = (mesh.points[i].y - y0) / hh;
				}
			}
			
			mesh.vedges = array_create_ext(array_length(mesh.edges), 
				function(i) /*=>*/ {return new __verlet_edge(mesh.points[mesh.edges[i][0]], mesh.points[mesh.edges[i][1]], __tens)}); 
		}
		
		outputs[0].setValue(mesh);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_verletsim_mesh, 0, bbox);
	}
	
}
