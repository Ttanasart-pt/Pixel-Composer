function Node_Smoke_Update(_x, _y, _group = noone) : Node_Smoke(_x, _y, _group) constructor {
	name  = "Update Fluid";
	color = COLORS.node_blend_smoke;
	icon  = THEME.smoke_sim;
	setDimension(96, 96);
	
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue("Domain", self, CONNECT_TYPE.input, VALUE_TYPE.sdomain, noone)).setVisible(true, true);
	
	newActiveInput(1);
	
	input_display_list = [
		["Domain",	false], 0,
		["Update",	false], 1,
	]
	
	newOutput(0, nodeValue_Output("Domain", VALUE_TYPE.sdomain, noone));
	
	static update = function(frame = CURRENT_FRAME) {
		if(!PROJECT.animator.is_playing) return;
		
		var _dom = inputs[0].getValue(frame);
		var _act = inputs[1].getValue(frame);
		
		SMOKE_DOMAIN_CHECK
		outputs[0].setValue(_dom);
		
		if(_act) _dom.update();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var _act = getInputData(1);
		draw_sprite_fit(_act? s_node_smoke_update : s_node_smoke_update_paused, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}