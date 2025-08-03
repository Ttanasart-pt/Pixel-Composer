function Node_VerletSim_Force(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Push Mesh";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	update_on_frame = true;
	setDimension(96, 48);
	
	newActiveInput(6);
	newInput(0, nodeValue_Mesh( "Mesh" )).setVisible(true, true);
	
	////- =Target
	newInput(1, nodeValue_Area(  "Area", DEF_AREA_REF )).setUnitRef(function(i) /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	newInput(2, nodeValue_Float( "Falloff", 0 ));
	newInput(4, nodeValue_Curve( "Falloff Curve", CURVE_DEF_01 ));
	
	////- =Force
	newInput(5, nodeValue_Float( "Strength", 1 ));
	newInput(3, nodeValue_Vec2(  "Push", [0,0] ));
	// input 7
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone));
	
	input_display_list = [ 6, 0, 
		[ "Target", false ], 1, 2, 4, 
		[ "Force",  false ], 5, 3, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _msh = getInputData(0);
		
		if(is(_msh, Mesh)) {
			draw_set_color(COLORS._main_icon);
			_msh.draw(_x, _y, _s);
		}
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		return w_hovering;
	}
	
	static update = function() {
		var _active = getInputData(6);
		var _mesh   = getInputData(0);
		outputs[0].setValue(_mesh);
		
		var _area     = getInputData(1);
		var _fall_dis = getInputData(2);
		var _fall_cur = getInputData(4);
		
		var _strn = getInputData(5);
		var _forc = getInputData(3);
		
		if(!_active) return;
		if(!is(_mesh, __verlet_Mesh)) return;
		
		var vx = _forc[0] * _strn / 10;
		var vy = _forc[1] * _strn / 10;
		
		for( var i = 0, n = array_length(_mesh.points); i < n; i++ ) {
			var  p  = _mesh.points[i];
			if(!is(p, __vec2) || p.pin) continue;
			
			var str = area_point_in_fallout(_area, p.x, p.y, _fall_dis);
			    str = eval_curve_x(_fall_cur, clamp(str, 0., 1.));
			
			p.x += str * vx;
			p.y += str * vy;
		}
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_verletsim_force, 0, bbox);
	}
}
