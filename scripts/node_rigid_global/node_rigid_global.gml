function Node_Rigid_Global(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "RigidSim Global";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	setDimension(96, 96);
	
	manual_ungroupable	 = false;
	
	object = noone;
	
	newInput(0, nodeValue_Vec2("Gravity", self, [ 0, 10 ]));
	
	current_gra = [0, 0];
	
	static update = function(frame = CURRENT_FRAME) {
		var _gra = getInputData(0);
		
		if(current_gra[0] != array_safe_get_fast(_gra, 0) || current_gra[1] != array_safe_get_fast(_gra, 1)) {
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