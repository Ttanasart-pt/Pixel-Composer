function Node_VerletSim_Mesh(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Mesh";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	parameters.inline_draw_input = true;
	
	setDrawIcon();
	setDimension(96, 48);
	
	////- =Mesh
	newInput( 0, nodeValue_Mesh(   "Mesh" )).setVisible(true, true);
	
	////- =Verlet
	newInput( 1, nodeValue_Slider( "Tension",  .5 ));
	newInput( 4, nodeValue_Slider( "Drag",      0 ));
	newInput( 5, nodeValue_Slider( "Stiffness", 0 ));
	
	////- =UV
	newInput( 2, nodeValue_Bool( "Remap",  false  ));
	newInput( 3, nodeValue_Area( "UV Map", DEF_AREA_REF, { useShape : false } )).setUnitSimple();
	// input 5
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone)).setCustomData(global.VERLET_MESH_JUNC);
	
	input_display_list = [ 
		[ "Mesh",   false    ],  0,  
		[ "Verlet", false    ],  1,  4, 
		[ "Map UV", false, 2 ],  3, 
	];
	
	////- Nodes
	
	mesh = noone;
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_VerletSim_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _msh = getInputData(0);
		var _uv  = getInputData(2);
		
		if(is(_msh, Mesh)) {
			draw_set_color(COLORS._main_icon);
			_msh.draw(_x, _y, _s);
		}
		
		if(_uv) drawOverlayInput(inputs[3].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		return w_hovering;
	}
	
	static update = function() {
		if(!IS_FIRST_FRAME) return;
		
		#region data
			var _msh  = getInputData(0);
			var _ten  = getInputData(1), _tens = 1 - _ten;
			var _drag = getInputData(4);
			var _adrg = getInputData(5);
			
			var _uv   = getInputData(2);
			var _uva  = getInputData(3);
			mesh = noone;
			
			if(!is(_msh, Mesh)) return;
		#endregion
		
		var x0 = _uva[0] - _uva[2]; 
		var y0 = _uva[1] - _uva[3];
		var ww = _uva[2] * 2;
		var hh = _uva[3] * 2;
		
		mesh = new __verlet_Mesh();
		mesh.edges     = array_clone(_msh.edges);
		mesh.triangles = array_clone(_msh.triangles);
		
		mesh.center    = array_clone(_msh.center);
		mesh.bbox      = array_clone(_msh.bbox);
		
		for( var i = 0, n = array_length(_msh.points); i < n; i++ ) {
			var p = _msh.points[i];
			if(!is(p, __vec2)) { mesh.points[i] = undefined; continue; }
			
			var _p = new __verlet_vec2().set2(p).setDrag(_drag);
			mesh.points[i] = _p;
			_p.index = i;
			
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
			
			mesh.vedges[i] = new __verlet_edge(p0, p1, _tens, _adrg); 
			_emap[$ mesh.vedges[i].toString()] = mesh.vedges[i];
		}
		
		var _amo = array_length(mesh.triangles);
		mesh.vtriangles = array_create(_amo);
		
		for( var i = 0; i < _amo; i++ ) {
			var t  = mesh.triangles[i];
			var p0 = mesh.points[t[0]];
			var p1 = mesh.points[t[1]];
			var p2 = mesh.points[t[2]];
			
			var T = new __verlet_triangle(p0, p1, p2);
			T.e0  = _emap[$ __verlet_edge_index(p0, p1)];
			T.e1  = _emap[$ __verlet_edge_index(p1, p2)];
			T.e2  = _emap[$ __verlet_edge_index(p2, p0)];
			
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
		
		outputs[0].setValue(mesh);
	}
	
}
