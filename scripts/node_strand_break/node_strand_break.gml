function Node_Strand_Break(_x, _y, _group = noone) : _Node_Strand_Affector(_x, _y, _group) constructor {
	name  = "Strand Break";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	setDimension(96, 48);
	setDrawIcon(s_node_strand_break);
	
	manual_ungroupable	 = false;
	
	var i = input_fix_len;
	
	////- =Break
	newInput(i+0, nodeValue_Slider("Chance", 1));
	newInput(i+1, nodeValueSeed());
	
	array_push(input_display_list, 
		[ "Break", false ], i+0, i+1
	);
	
	////- Node
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var i = input_fix_len;
			
			var _pos = getInputData(2);
			var _dir = getInputData(4);
		
			var _cha = getInputData(i+0);
			var _sed = getInputData(i+1);
		#endregion
			
		var _pos1 = [
			_pos[0] + lengthdir_x(16, _dir),
			_pos[1] + lengthdir_y(16, _dir),
		];
		
		STRAND_EFFECTOR_PRE
			if(_sed && random1D(h.id) < _cha * mulp)
				h.free = true;
				
			else if(!_sed && random(1) < _cha * mulp)
				h.free = true;
		STRAND_EFFECTOR_POST
	}
	
}