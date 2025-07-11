function Node_VerletSim_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "VerletSim";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	
	is_simulation      = true;
	input_node_types   = [ Node_VerletSim_Mesh   ];
	output_node_types  = [ Node_VerletSim_Render ];
	
	newInput(0, nodeValue_Int(  "Substep",   8     ));
	newInput(1, nodeValue_Vec2( "Gravity",  [0,.5] ));
	// input 2
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone));
	
	input_display_list = [ 
		[ "Simulation", false ], 0, 1, 
	];
	
	verlet_substep = 8;
	verlet_gravity = [0,0];
	
	if(NODE_NEW_MANUAL) {
		var _mesh   = nodeBuild("Node_VerletSim_Mesh",   x,       y, self);
		var _render = nodeBuild("Node_VerletSim_Render", x + 160, y, self);
		
		_render.inputs[0].setFrom(_mesh.outputs[0]);
		
		addNode(_mesh);
		addNode(_render);
	}
	
	////- Verlet
	
	function verletPropagate(_mesh, _substep) {
		var _points = _mesh.points;
		
		var grav_x = verlet_gravity[0] / _substep / 10;
		var grav_y = verlet_gravity[1] / _substep / 10;
	 	
		for( var i = 0, n = array_length(_points); i < n; i++ ) {
			var p = _points[i];
			if(!is(p, __vec2)) continue;
			
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
	
	function verletConstrain(_mesh, _substep) {
		var _points = _mesh.points;
		var _edges  = _mesh.vedges;
		
		for( var i = 0, n = array_length(_edges); i < n; i++ ) {
			var e = _edges[i];
			if(!e.active) continue;
			
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
	
	function verletStep(_mesh, _substep = verlet_substep) {
		repeat(_substep) {
			verletPropagate(_mesh, _substep);
			verletConstrain(_mesh, _substep);
		}
		
	}
	
	////- Nodes
	
	static update = function() {
		verlet_substep = inputs[0].getValue();
		verlet_gravity = inputs[1].getValue();
	}
	
}

