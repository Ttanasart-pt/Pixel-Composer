function Node_Strand_Break(_x, _y, _group = noone) : _Node_Strand_Affector(_x, _y, _group) constructor {
	name  = "Strand Break";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	setDimension(96, 48);
	setDrawIcon(s_node_strand_break);
	
	manual_ungroupable	 = false;
	
	newInput(input_fix_len + 0, nodeValue_Slider("Chance", 1));
	
	newInput(input_fix_len + 1, nodeValueSeed());
	
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
	
}