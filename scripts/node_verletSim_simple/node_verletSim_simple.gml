function Node_VerletSim_Simple(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Verlet";
	update_on_frame = true;
	
	newInput(0, nodeValue_Mesh( "Mesh" )).setVisible(true, true);
	
	newInput(1, nodeValue_Int(  "Substep",   8     ));
	newInput(2, nodeValue_Vec2( "Gravity",  [0,.5] ));
	
	// input 3
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone));
	
	input_display_list = [ 0,
		[ "Simulation", false ], 1, 2, 
	];
	
	////- Verlet
	
	function verletPropagate(_mesh, _substep) {
		var _points = _mesh.points;
		
		var grav   = getInputData(2);
		var grav_x = grav[0] / _substep;
		var grav_y = grav[1] / _substep;
		
		for( var i = 0, n = array_length(_points); i < n; i++ ) {
			var p = _points[i];
			
			var _vx = p.x - p.px;
			var _vy = p.y - p.py;
			
			p.px = p.x;
			p.py = p.y;
			
			_vx += grav_x;
			_vy += grav_y;
			
			if(!p.pin) {
				p.x += _vx;
				p.y += _vy;
			}
		}
		
		// for( var i = 0, n = array_length(_points); i < n; i++ ) {
		// 	var p = _points[i];
		// 	if(p.y > 64) p.y = 64;
		// }
		
	}
	
	function verletConstrain(_mesh, _substep) {
		var _points = _mesh.points;
		var _edges  = _mesh.vedges;
		
		for( var i = 0, n = array_length(_edges); i < n; i++ ) {
			var e = _edges[i];
			var p0 = e.p0;
			var p1 = e.p1;
			
			if(p0.pin && p1.pin) {
				p0.x = p0.px; p0.y = p0.py;
				p1.x = p1.px; p1.y = p1.py;
				continue;
			}
			
			var odist = e.distance;
			var ndist = point_distance(p0.x, p0.y, p1.x, p1.y);
			var sdist = lerp(odist, ndist, e.k);
			var dirr  = point_direction(p0.x, p0.y, p1.x, p1.y);
			
			if(p0.pin) {
				p0.x = p0.px; 
				p0.y = p0.py;

				p1.x = p0.x + lengthdir_x(sdist, dirr);
				p1.y = p0.y + lengthdir_y(sdist, dirr);
				
			} else if(p1.pin) {
				p0.x = p1.x - lengthdir_x(sdist, dirr);
				p0.y = p1.y - lengthdir_y(sdist, dirr);
				
				p1.x = p1.px; 
				p1.y = p1.py;
				
			} else {
				var cx = (p0.x + p1.x) / 2;
				var cy = (p0.y + p1.y) / 2;
				
				p0.x = cx - lengthdir_x(sdist / 2, dirr);
				p0.y = cy - lengthdir_y(sdist / 2, dirr);
				
				p1.x = cx + lengthdir_x(sdist / 2, dirr);
				p1.y = cy + lengthdir_y(sdist / 2, dirr);
				
			}
		}
	}
	
	function verletStep(_mesh, _substep = 4) {
		repeat(_substep) {
			verletPropagate(_mesh, _substep);
			verletConstrain(_mesh, _substep);
		}
		
	}
	
	////- Nodes
	
	mesh = noone;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(!is(mesh, Mesh)) return w_hovering;
		
		draw_set_color(COLORS._main_icon);
		mesh.draw(_x, _y, _s);
		
		return w_hovering;
	}
	
	static step = function() {}
	
	static update = function() {
		if(IS_FIRST_FRAME) {
			var _msh = inputs[0].getValue();
			var _ten = inputs[2].getValue(); __tens = 1 - _ten;
			
			mesh = noone;
			
			if(is(_msh, __verlet_Mesh)) {
				mesh = _msh;
				
			} else if(is(_msh, Mesh)) {
				mesh = new __verlet_Mesh();
				
				mesh.edges     = array_clone(_msh.edges);
				mesh.triangles = array_clone(_msh.triangles);
				
				mesh.center    = array_clone(_msh.center);
				mesh.bbox      = array_clone(_msh.bbox);
				
				for( var i = 0, n = array_length(mesh.points); i < n; i++ )
					mesh.points[i] = new __verlet_vec2().set2(mesh.points[i]);
				
				mesh.vedges = array_create_ext(array_length(mesh.edges), 
					function(i) /*=>*/ {return new __verlet_edge(mesh.points[mesh.edges[i][0]], mesh.points[mesh.edges[i][1]], 1)}); 
			}
		}
		
		outputs[0].setValue(mesh);
		if(!is(mesh, __verlet_Mesh)) return;
		
		var _sstep = inputs[1].getValue();
		
		verletStep(mesh, _sstep);
		
	}
	
	
}
