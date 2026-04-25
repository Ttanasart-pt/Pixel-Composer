function Node_Strand_Length_Adjust(_x, _y, _group = noone) : _Node_Strand_Affector(_x, _y, _group) constructor {
	name  = "Strand Length";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	setDimension(96, 48);
	setDrawIcon(s_node_strand_length_adjust);
	
	manual_ungroupable	 = false;
	var i = input_fix_len;
	
	////- =Length adjust
	newInput(i+0, nodeValue_Enum_Button("Type",  0, [ "Increase", "Decrease" ]));
	newInput(i+1, nodeValue_Slider("Strength", 0.1));
		
	array_push(input_display_list, 
		[ "Length adjust", false ], i+0, i+1,
	);
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var i = input_fix_len;
			var _sTyp = getInputData(i+0);
			var _sStr = getInputData(i+1);
		#endregion
		
		STRAND_EFFECTOR_PRE
			h.length[j] *= 1 + (_sTyp? -1 : 1) * mulp * _sStr;
		STRAND_EFFECTOR_POST
	}
	
}