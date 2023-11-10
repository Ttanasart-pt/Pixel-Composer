function Node_Fluid_Update(_x, _y, _group = noone) : Node_Fluid(_x, _y, _group) constructor {
	name  = "Update Fluid";
	color = COLORS.node_blend_smoke;
	icon  = THEME.smoke_sim;
	w = 96;
	min_h = 96;
	
	inputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.input, VALUE_TYPE.fdomain, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	input_display_list = [
		["Domain",	false], 0,
		["Update",	false], 1,
	]
	
	outputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.output, VALUE_TYPE.fdomain, noone);
	
	static update = function(frame = CURRENT_FRAME) {
		if(!PROJECT.animator.is_playing) return;
		
		var _dom = inputs[| 0].getValue(frame);
		var _act = inputs[| 1].getValue(frame);
		
		FLUID_DOMAIN_CHECK
		outputs[| 0].setValue(_dom);
		
		if(!_act) return;
		if(is_surface(_dom.sf_world)) 
			fd_rectangle_update(_dom);
		texture_set_interpolation(false);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var _act = getInputData(1);
		draw_sprite_fit(_act? s_node_smokeSim_update : s_node_smokeSim_update_paused, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}