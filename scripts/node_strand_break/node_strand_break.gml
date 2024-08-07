function Node_Strand_Break(_x, _y, _group = noone) : _Node_Strand_Affector(_x, _y, _group) constructor {
	name  = "Strand Break";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	setDimension(96, 48);;
	
	manual_ungroupable	 = false;
	
	inputs[| input_fix_len + 0] = nodeValue_Float("Chance", self, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| input_fix_len + 1] = nodeValue_Int("Seed", self, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[| input_fix_len + 1].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	array_push(input_display_list, 
		["Break",	false], input_fix_len + 0, input_fix_len + 1
	);
	
	static update = function(frame = CURRENT_FRAME) {
		var _cha = getInputData(input_fix_len + 0);
		var _sed = getInputData(input_fix_len + 1);
		
		STRAND_EFFECTOR_PRE
			if(_sed && random1D(h.id) < _cha * mulp)
				h.free = true;
			else if(!_sed && random(1) < _cha * mulp)
				h.free = true;
		STRAND_EFFECTOR_POST
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_strandSim_break, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}