function Node_Strand_Length_Adjust(_x, _y, _group = noone) : _Node_Strand_Affector(_x, _y, _group) constructor {
	name = "Strand Length";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	w = 96;
	
	inputs[| input_fix_len + 0] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Increase", "Decrease" ]);
	
	inputs[| input_fix_len + 1] = nodeValue("Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ]);
		
	array_push(input_display_list, 
		["Length adjust",	false], input_fix_len + 0, input_fix_len + 1,
	);
	
	static update = function(frame = ANIMATOR.current_frame) {
		var _sTyp = inputs[| input_fix_len + 0].getValue();
		var _sStr = inputs[| input_fix_len + 1].getValue();
		
		STRAND_EFFECTOR_PRE
			h.length[j] *= 1 + (_sTyp? -1 : 1) * mulp * _sStr;
		STRAND_EFFECTOR_POST
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_strandSim_length, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}