function Node_Strand_Update(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Strand Update";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	setDimension(96, 48);
	setDrawIcon(s_node_strand_update);
	
	manual_ungroupable	 = false;
	
	newInput( 0, nodeValue_Strand());
	
	////- =Update
	newInput( 1, nodeValue_Int("Step",      4 ))
	newInput( 2, nodeValue_Int("Iteration", 8 ))
	// 3
	
	newOutput(0, nodeValue_Output("Strand", VALUE_TYPE.strands, noone));
	
	input_display_list = [ 0, 
		[ "Update", false ], 1, 2, 
	];
	
	////- Node
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _str = getInputData(0);
			var _stp = getInputData(1);
			var _itr = getInputData(2);
		#endregion
		
		if(_str == noone) return;
		var __str = _str;
		if(!is_array(_str)) __str = [ _str ];
		
		for( var i = 0, n = array_length(__str); i < n; i++ ) 
			__str[i].step(_stp, _itr);
		outputs[0].setValue(_str);
	}
	
}