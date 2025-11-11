function Node_Strand_Length_Adjust(_x, _y, _group = noone) : _Node_Strand_Affector(_x, _y, _group) constructor {
	name  = "Strand Length";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	setDimension(96, 48);
	
	manual_ungroupable	 = false;
	
	newInput(input_fix_len + 0, nodeValue_Enum_Button("Type",  0, [ "Increase", "Decrease" ]));
	
	newInput(input_fix_len + 1, nodeValue_Slider("Strength", 0.1));
		
	array_push(input_display_list, 
		["Length adjust",	false], input_fix_len + 0, input_fix_len + 1,
	);
	
	static update = function(frame = CURRENT_FRAME) {
		var _sTyp = getInputData(input_fix_len + 0);
		var _sStr = getInputData(input_fix_len + 1);
		
		STRAND_EFFECTOR_PRE
			h.length[j] *= 1 + (_sTyp? -1 : 1) * mulp * _sStr;
		STRAND_EFFECTOR_POST
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		draw_sprite_fit(s_node_strand_length_adjust, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}