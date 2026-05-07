#region global
	global.VERLET_MESH_JUNC = {
		icon:  function() /*=>*/ {return THEME.node_junction_verlet},
		color: function() /*=>*/ {return COLORS.node_blend_verlet},
	}
	
#endregion

function Node_VerletSim_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "VerletSim";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	is_simulation = true;
	
	////- =Domain
	newInput( 2, nodeValue_Dimension());
	newInput( 3, nodeValue_Toggle( "Wall", 0b0000, [ "T", "B", "L", "R" ] ));
	
	////- =Simulation
	newInput( 0, nodeValue_Int(  "Substep",   8     ));
	newInput( 1, nodeValue_Vec2( "Gravity",  [0,.5] ));
	// input 4
	
	newOutput( 0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone)).setCustomData(global.VERLET_MESH_JUNC);
	
	input_display_list = [ 
		[ "Domain",     false ],  2,  3, 
		[ "Simulation", false ],  0,  1, 
	];
	
	////- Node
	
	verlet_substep   = 8;
	verlet_gravity   = [0,0];
	verlet_dimension = [1,1];
	verlet_wall      = 0b0000;
	
	if(NODE_NEW_MANUAL) {
		var _mesh   = nodeBuild(Node_VerletSim_Mesh_Grid, x,       y, self);
		var _render = nodeBuild(Node_VerletSim_Render,    x + 160, y, self);
		
		_render.inputs[0].setFrom(_mesh.outputs[0]);
		
		addNode(_mesh);
		addNode(_render);
	}
	
	static getDimension = function() /*=>*/ {return verlet_dimension};
	
	////- Verlet
	
	function verletPropagate(_mesh, _substep) {
		var _points = _mesh.points;
		
		var grav_x = verlet_gravity[0] / _substep / 10;
		var grav_y = verlet_gravity[1] / _substep / 10;
	 	var amo = array_length(_points), i = 0;
	 	
		repeat(amo) {
			var p = _points[i++];
			if(!is(p, __verlet_vec2) || p.rest) continue;
			
			var _vx = p.x - p.px;
			var _vy = p.y - p.py;
			
			p.px = p.x;
			p.py = p.y;
			
			_vx += grav_x;
			_vy += grav_y;
			
			if(!p.pin) {
				p.x += _vx;
				p.y += _vy;
				
				p.x = lerp(p.px, p.x, 1 - power(p.drag, 4));
				p.y = lerp(p.py, p.y, 1 - power(p.drag, 4));
			}
			
		}
		
	}
	
	function verletCollide(_mesh, _substep) {
		var _points = _mesh.points;
	 	var amo = array_length(_points), i = 0;
	 	
	 	if(verlet_wall & 0b0001) repeat(amo) { // T
			var p = _points[i++];
			if(!is(p, __verlet_vec2) || p.rest) continue;
			if(p.y < 0) {
				p.rest = true;
				p.y = 0;
			}
	 	}
	 	
	 	if(verlet_wall & 0b0010) repeat(amo) { // B
			var p = _points[i++];
			if(!is(p, __verlet_vec2) || p.rest) continue;
			if(p.y > verlet_dimension[1]) {
				p.rest = true;
				p.y = verlet_dimension[1];
			}
	 	}
	 	
	 	if(verlet_wall & 0b0100) repeat(amo) { // L
			var p = _points[i++];
			if(!is(p, __verlet_vec2) || p.rest) continue;
			if(p.x < 0) {
				p.rest = true;
				p.x = 0;
			}
	 	}
	 	
	 	if(verlet_wall & 0b1000) repeat(amo) { // R
			var p = _points[i++];
			if(!is(p, __verlet_vec2) || p.rest) continue;
			if(p.x > verlet_dimension[0]) {
				p.rest = true;
				p.x = verlet_dimension[0];
			}
	 	}
	}
	
	function verletConstrainEdge(_mesh, _substep) {
		var _edges  = _mesh.vedges;
		var amo = array_length(_edges), i = 0;
	 	
		repeat(amo) {
			var e = _edges[i++];
			if(!e.active) continue;
			
			var p0 = e.p0;
			var p1 = e.p1;
			
			if(!p0.active || !p1.active) {
				e.active = false;
				continue;
			}
			
			if(p0.pin && p1.pin) {
				p0.x = p0.px; p0.y = p0.py;
				p1.x = p1.px; p1.y = p1.py;
				continue;
			}
			
			// if(p0.rest || p1.rest) { 
			// 	p0.rest = true;
			// 	p1.rest = true;
			// }
			
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
	
	function verletStep(_mesh, _substep = verlet_substep) {
		repeat(_substep) {
			verletPropagate(_mesh, _substep);
			verletCollide(_mesh, _substep);
			verletConstrainEdge(_mesh, _substep);
		}
		
	}
	
	////- Nodes
	
	static update = function() {
		verlet_dimension = inputs[2].getValue();
		verlet_wall      = inputs[3].getValue();
		
		verlet_substep   = inputs[0].getValue();
		verlet_gravity   = inputs[1].getValue();
	}
	
}

