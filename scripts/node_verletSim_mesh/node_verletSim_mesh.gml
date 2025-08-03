function Node_VerletSim_Mesh(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Mesh";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	
	setDimension(96, 48);
	
	////- =Mesh
	newInput(0, nodeValue_Mesh(   "Mesh" )).setVisible(true, true);
	newInput(1, nodeValue_Slider( "Tension",  .5 ));
	newInput(4, nodeValue_Slider( "Drag",      0 ));
	
	////- =UV
	newInput(2, nodeValue_Bool( "Remap",  false  ));
	newInput(3, nodeValue_Area( "UV Map", DEF_AREA_REF, { useShape : false } )).setUnitRef(function(i) /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	
	// input 5
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone));
	
	input_display_list = [ 
		[ "Mesh",   false ], 0, 1, 4, 
		[ "Map UV", false, 2 ], 3, 
	];
	
	////- Nodes
	
	mesh = noone;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
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
		
		var _msh  = getInputData(0);
		var _ten  = getInputData(1); __tens = 1 - _ten;
		var _drag = getInputData(4);
		
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
				var p = _msh.points[i];
				if(!is(p, __vec2)) { mesh.points[i] = undefined; continue; }
				
				var _p = new __verlet_vec2().set2(p);
				mesh.points[i] = _p;
				_p.drag = _drag;
				
				if(is(p, __vec2UV)) { 
					_p.u = p.u;
					_p.v = p.v;
				}
				
				if(_uv) {
					_p.u = (_p.x - x0) / ww;
					_p.v = (_p.y - y0) / hh;
				}
			}
			
			var _amo  = array_length(mesh.edges);
			var _emap = {};
			mesh.vedges = array_create(_amo);
			
			for( var i = 0; i < _amo; i++ ) {
				var e  = mesh.edges[i];
				var p0 = mesh.points[e[0]];
				var p1 = mesh.points[e[1]];
				
				mesh.vedges[i] = new __verlet_edge(p0, p1, __tens); 
				_emap[$ mesh.vedges[i].toString()] = mesh.vedges[i];
			}
			
			var _amo = array_length(mesh.triangles);
			mesh.vtriangles = array_create(_amo);
			
			for( var i = 0; i < _amo; i++ ) {
				var t  = mesh.triangles[i];
				var p0 = mesh.points[t[0]];
				var p1 = mesh.points[t[1]];
				var p2 = mesh.points[t[2]];
				
				var T  = new __verlet_triangle(p0, p1, p2);
				
				var e0 = p0.lessThan(p1)? $"{p0}-{p1}" : $"{p1}-{p0}";
				var e1 = p1.lessThan(p2)? $"{p1}-{p2}" : $"{p2}-{p1}";
				var e2 = p2.lessThan(p0)? $"{p2}-{p0}" : $"{p0}-{p2}";
				
				T.e0 = _emap[$ e0];
				T.e1 = _emap[$ e1];
				T.e2 = _emap[$ e2];
				
				mesh.vtriangles[i] = T;
			}
			
			if(_msh.quads != undefined) {
				var _amo    = array_length(_msh.quads);
				mesh.vquads = array_create(_amo);
				
				for( var i = 0; i < _amo; i++ ) {
					var q  = _msh.quads[i];
					var t0 = mesh.vtriangles[q[0]];
					var t1 = mesh.vtriangles[q[1]];
					
					mesh.vquads[i] = new __verlet_quad(t0, t1);
				}
			}
		}
		
		outputs[0].setValue(mesh);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_verletsim_mesh, 0, bbox);
	}
	
}
