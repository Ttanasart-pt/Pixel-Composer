function Node_Rigid_Global(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "RigidSim Global";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	w = 96;
	min_h = 96;
	
	object = noone;
	
	inputs[| 0] = nodeValue("Gravity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 10 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	current_gra = [0, 0];
	
	static update = function(frame = PROJECT.animator.current_frame) {
		var _gra = getInputData(0);
		
		if(current_gra[0] != array_safe_get(_gra, 0) || current_gra[1] != array_safe_get(_gra, 1)) {
			physics_world_gravity(_gra[0], _gra[1]);
			
			current_gra[0] = _gra[0];
			current_gra[1] = _gra[1];
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_rigidSim_global, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}